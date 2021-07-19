//
//  SceneDelegate.swift
//  SneakersnShit
//
//  Created by István Kreisz on 12/13/20.
//

import UIKit
import SwiftUI
// import FacebookLogin
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let store = AppStore(initialState: .init(), reducer: appReducer, environment: World(isMockInstance: false))

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }

        setupUI()

        let rootView = RootView().environmentObject(store)
        let window = UIWindow(windowScene: scene)
        let rootViewController = UIHostingController(rootView: rootView)
        window.rootViewController = rootViewController

        #warning("yo")
//        GIDSignIn.sharedInstance.presentingViewController = rootViewController
//        GIDSignIn.sharedInstance.restorePreviousSignIn()
        
        self.window = window
        window.makeKeyAndVisible()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        guard let context = URLContexts.first else { return }
        
//        ApplicationDelegate.shared.application(UIApplication.shared,
//                                               open: context.url,
//                                               sourceApplication: context.options.sourceApplication,
//                                               annotation: context.options.annotation)
    }

    private func setupUI() {
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().showsVerticalScrollIndicator = false
        UITableViewCell.appearance().selectionStyle = .none
        UINavigationBar.appearance().backgroundColor = UIColor.clear
    }
}
