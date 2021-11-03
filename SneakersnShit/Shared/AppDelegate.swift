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
        AppStore.default.environment.pushNotificationService.setup(application: application)
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

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppStore.default.environment.pushNotificationService.application(application,
                                                                         didReceiveRemoteNotification: userInfo,
                                                                         fetchCompletionHandler: completionHandler)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
}
