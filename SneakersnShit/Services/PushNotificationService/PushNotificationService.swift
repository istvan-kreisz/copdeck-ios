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
    private var userId: String?
    private let topics = ["all", "alliOS"]

    let latestMessageSubject = CurrentValueSubject<(messageId: String, channelId: String)?, Never>(nil)

    var deviceId: String {
        UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }

    func setup(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        #warning("where to call this?")
        requestUserPermission()
    }

    func requestUserPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { _, _ in })
        UIApplication.shared.registerForRemoteNotifications()
    }

    func setup(userId: String) {
        self.userId = userId
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
                                                                                 deviceId: self.deviceId,
                                                                                 refreshedDate: Date.serverDate)
                                    self.updateTokenInDB(newNotificationToken)
                                }
                            }
                        }
                    } else {
                        let newToken = NotificationToken(token: token,
                                                         userId: userId,
                                                         deviceId: self.deviceId,
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
            completion()
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
    #warning("do we need to implement this? - decide how to present")
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        print(userInfo)
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
            completionHandler([[.sound, .badge]])
        } else {
            completionHandler([[.sound, .badge]])
        }
    }

    #warning("do we need to implement this? - react to user interaction")
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
        print("---------")

        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            print("")
            break
        case UNNotificationDismissActionIdentifier:
            break
        default:
            break
        }
        completionHandler()
    }
}

extension PushNotificationService: MessagingDelegate {
    #warning("what to do here?")
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
//        let dataDict: [String: String] = ["token": fcmToken ?? ""]
//        NotificationCenter.default.post(name: Notification.Name("FCMToken"),
//                                        object: nil,
//                                        userInfo: dataDict)
//    }
}
