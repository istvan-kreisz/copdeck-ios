//
//  AppDelegate.swift
//  CopDeck
//
//  Created by István Kreisz on 12/13/20.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import Nuke
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if DebugSettings.shared.clearUserDefaults {
            UserDefaults.standard.reset()
        }
        FirebaseConfiguration.shared.setLoggerLevel(DebugSettings.shared.isInDebugMode ? .info : .min)
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        StoreReviewHelper.incrementAppOpenedCount()
        setupNuke()
        setupUI()

        return true
    }

    private func setupNuke() {
        ImagePipeline.shared = ImagePipeline(configuration: .withDataCache)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(UIApplication.shared,
                                               open: url,
                                               sourceApplication: nil,
                                               annotation: [UIApplication.OpenURLOptionsKey.annotation])
        return GIDSignIn.sharedInstance.handle(url)
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    private func setupUI() {
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().showsVerticalScrollIndicator = false
        UITableViewCell.appearance().selectionStyle = .none
        UINavigationBar.appearance().backgroundColor = UIColor.clear
        UITextView.appearance().backgroundColor = UIColor(red: 243 / 255, green: 246 / 255, blue: 248 / 255, alpha: 1.0)
    }

    private func setupNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        #warning("request later")
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
        application.registerForRemoteNotifications()

        Messaging.messaging().delegate = self
    }

    private var token: String?
}

extension AppDelegate: UNUserNotificationCenterDelegate {}

extension AppDelegate: MessagingDelegate {

    #warning("when swizzling is disabled")
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      Messaging.messaging().apnsToken = deviceToken
    }

    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        self.token = fcmToken

        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"),
                                        object: nil,
                                        userInfo: dataDict)
//        Messaging.messaging().token { token, error in
//            if let error = error {
//                print("Error fetching FCM registration token: \(error)")
//            } else if let token = token {
//                print("FCM registration token: \(token)")
//                self.fcmRegTokenMessage.text = "Remote FCM registration token: \(token)"
//            }
//        }
    }
}
