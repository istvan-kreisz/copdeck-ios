//
//  AppDelegate.swift
//  SneakersnShit
//
//  Created by István Kreisz on 12/13/20.
//

import UIKit
import Firebase
import GoogleSignIn
// import FacebookCore
// import FacebookLogin

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _ = IAPHelper.shared
        FirebaseApp.configure()
//        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        StoreReviewHelper.incrementAppOpenedCount()

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//        ApplicationDelegate.shared.application(app,
//                                               open: url,
//                                               sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
//                                               annotation: options[UIApplication.OpenURLOptionsKey.annotation]
//        )
        return GIDSignIn.sharedInstance.handle(url)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
