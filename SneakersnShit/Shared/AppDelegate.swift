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
import Purchases

/// Users/istvankreisz/Workspace/CopDeck/App/Code/Pods/FirebaseCrashlytics/upload-symbols -gsp /Users/istvankreisz/Workspace/CopDeck/App/Code/SneakersnShit/Shared/GoogleService-Info.plist -p ios /Users/istvankreisz/Desktop/appDsyms
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if DebugSettings.shared.clearUserDefaults {
            UserDefaults.standard.reset()
        }
        _ = IAPHelper.shared
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        StoreReviewHelper.incrementAppOpenedCount()
        setupNuke()
        setupUI()
        setupRevenueCat()
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
    }

    private func setupRevenueCat() {
        Purchases.debugLogsEnabled = DebugSettings.shared.isInDebugMode
        Purchases.configure(withAPIKey: "vkJAtxOkCMEORPnQDmuEwtoUBuHDUMSu")

        Purchases.shared.offerings { offerings, error in
            if let package = offerings?.current?.monthly?.product {
                print("--package--")
                print(package.productIdentifier)

                Purchases.shared.purchasePackage(package) { transaction, purchaserInfo, error, userCancelled in
                    if purchaserInfo.entitlements[""]?.isActive == true {
                        // Unlock that great "pro" content
                    }
                }
            }
        }
    }
}
