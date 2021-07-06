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
        GIDSignIn.sharedInstance()?.presentingViewController = rootViewController
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
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

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
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
