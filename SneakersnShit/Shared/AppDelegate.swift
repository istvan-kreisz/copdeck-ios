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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _ = IAPHelper.shared
        FirebaseApp.configure()
//        GIDSignIn.sharedInstance.clientID = FirebaseApp.app()?.options.clientID
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
//        GIDSignIn.sharedInstance.handle(url)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
