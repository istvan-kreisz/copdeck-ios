//
//  PushNotificationService.swift
//  CopDeck
//
//  Created by István Kreisz on 11/3/21.
//

import Foundation
import UIKit
import FirebaseMessaging
import Combine

class PushNotificationService: NSObject {
    private let gcmMessageIDKey = "gcm.message_id"
    private let topics = ["all", "alliOS"]

    let lastMessageChannelIdSubject = CurrentValueSubject<String?, Never>(nil)

    private var userId: String? {
        didSet {
            if let userId = userId, didGrantNotificationPermission {
                setupToken(userId: userId)
            }
        }
    }

    private var didGrantNotificationPermission: Bool = false {
        didSet {
            if let userId = userId, didGrantNotificationPermission {
                setupToken(userId: userId)
            }
        }
    }

    static var deviceId: String {
        UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }

    func setup(application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().isAutoInitEnabled = false

        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            self?.handlePermissionBlockResult(isGranted: settings.authorizationStatus == .authorized, saveResult: false, completion: nil)
        }
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler(UIBackgroundFetchResult.noData)
    }
    
    func requestPermissionsIfNotAsked(completion: (() -> Void)?) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            if settings.authorizationStatus == .notDetermined {
                self?.requestUserPermission(completion: completion)
            } else {
                completion?()
            }
        }
    }

    func requestUserPermission(completion: (() -> Void)?) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] didGrant, error in
            self?.handlePermissionBlockResult(isGranted: didGrant, saveResult: true, completion: completion)
        }
    }
    
    private func handlePermissionBlockResult(isGranted: Bool, saveResult: Bool, completion: (() -> Void)?) {
        if isGranted {
            DispatchQueue.main.async { [weak self] in
                UIApplication.shared.registerForRemoteNotifications()
                self?.didGrantNotificationPermission = true
                if saveResult {
                    AppStore.default.send(.main(action: .enabledNotifications))
                }
                completion?()
            }
        }
    }

    func setup(userId: String) {
        self.userId = userId
    }

    private func setupToken(userId: String) {
        delay(seconds: 2) { [weak self] in
            self?.getToken { [weak self] token in
                guard let token = token else { return }
                AppStore.default.environment.dataController.getToken(byId: token) { [weak self] notificationToken in
                    guard let self = self else { return }
                    if var notificationToken = notificationToken {
                        if userId == notificationToken.userId {
                            if notificationToken.refreshedDate.isOlderThan(days: 14) {
                                notificationToken.refreshedDate = Date.serverDate
                                self.updateTokenInDB(notificationToken)
                            } else {
                                // do nothing
                            }
                        } else {
                            self.deleteToken(byId: token) { [weak self] in
                                self?.getToken { [weak self] newToken in
                                    guard let self = self, let newToken = newToken else { return }

                                    let newNotificationToken = NotificationToken(token: newToken,
                                                                                 userId: userId,
                                                                                 deviceId: Self.deviceId,
                                                                                 refreshedDate: Date.serverDate)
                                    self.updateTokenInDB(newNotificationToken)
                                }
                            }
                        }
                    } else {
                        let newToken = NotificationToken(token: token,
                                                         userId: userId,
                                                         deviceId: Self.deviceId,
                                                         refreshedDate: Date.serverDate)
                        self.updateTokenInDB(newToken)
                    }
                }
            }
        }
    }

    func reset() {
        getToken { [weak self] token in
            guard let token = token else { return }
            self?.deleteToken(byId: token) {}
        }
    }

    private func delay(seconds: TimeInterval, completion: @escaping () -> Void) {
        Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { _ in
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    private func subscribeToDefaultTopics() {
        topics.forEach { subscribeToken(toTopic: $0) }
    }

    private func subscribeToken(toTopic topic: String) {
        Messaging.messaging().subscribe(toTopic: topic)
    }

    private func updateTokenInDB(_ token: NotificationToken) {
        AppStore.default.environment.dataController.setToken(token) { [weak self] result in
            switch result {
            case let .failure(error):
                log(error, logType: .error)
            case let .success(tokensToDelete):
                self?.deleteTokens(tokensToDelete)
                self?.subscribeToDefaultTopics()
            }
        }
    }

    private func getToken(completion: @escaping (String?) -> Void) {
        Messaging.messaging().token { token, error in
            completion(token)
        }
    }

    private func deleteToken(byId id: String, completion: @escaping () -> Void) {
        Messaging.messaging().deleteToken { [weak self] _ in
            self?.deleteTokenInDB(byId: id)
        }
    }

    private func deleteTokens(_ tokens: [NotificationToken]) {
        tokens.forEach { token in
            topics.forEach { topic in
                Messaging.messaging().unsubscribe(fromTopic: topic)
            }
            deleteTokenInDB(byId: token.token)
        }
    }

    private func deleteTokenInDB(byId id: String) {
        AppStore.default.environment.dataController.deleteToken(byId: id) { error in
            if let error = error {
                log(error, logType: .error)
            }
        }
    }
}

extension PushNotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        Messaging.messaging().appDidReceiveMessage(userInfo)

        if notification.isChatMessage {
            if ViewRouter.shared.currentPage != .chat && !AppStore.isChatDetailView {
                completionHandler([[.sound, .badge, .banner]])
            } else {
                completionHandler([[.sound, .badge]])
            }
        } else {
            completionHandler([[.sound, .badge]])
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        Messaging.messaging().appDidReceiveMessage(userInfo)

        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            if response.notification.isChatMessage {
                if let channelId = userInfo["channelId"] as? String {
                    lastMessageChannelIdSubject.send(channelId)
                }
            }
        case UNNotificationDismissActionIdentifier:
            break
        default:
            break
        }
        completionHandler()
    }
}

extension UNNotification {
    var isChatMessage: Bool {
        (request.content.userInfo["type"] as? String) == "chat"
    }
}
