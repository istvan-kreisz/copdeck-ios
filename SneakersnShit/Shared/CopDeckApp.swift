//
//  CopDeckApp.swift
//  CopDeck
//
//  Created by István Kreisz on 7/20/21.
//

import SwiftUI
import Firebase

@main
struct CopDeckApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    @State var selectedIndex = 0
    let titles = ["First", "Second", "Third", "Fourth", "Fifth", "Sixth", "Seventh", "Eighth"]

    var body: some Scene {
        WindowGroup {
            HorizontalPagingViewWithSegmentedControl()

//            RootView()
//                .environmentObject(AppStore.default)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                break
            case .active:
                break
            case .inactive:
                break
            @unknown default:
                break
            }
        }
    }
}
