//
//  Main.swift
//  CopDeck
//
//  Created by István Kreisz on 1/28/21.
//

import SwiftUI
import FirebaseFunctions

struct MainContainerView: View {
    var store: AppStore
    @StateObject var viewRouter = ViewRouter.shared
    @State var shouldShowTabBar = true
    @State var lastMessageChannelId: String?

    var body: some View {
        let selectedIndex = Binding<Int>(get: { viewRouter.currentPage.rawValue }, set: { viewRouter.currentPage = Page(rawValue: $0) ?? .search })
        UITabBarWrapper(selectedIndex: selectedIndex) {
            (TabBarElement(tabBarElementItem: .init(title: "First", systemImageName: "house.fill")) {
                FeedView(userId: store.state.user?.id ?? "")
                    .withTabViewWrapper(viewRouter: viewRouter, store: FeedStore.default, shouldShow: $shouldShowTabBar)
            },
            TabBarElement(tabBarElementItem: .init(title: "Second", systemImageName: "pencil.circle.fill")) {
                SearchView()
                    .withTabViewWrapper(viewRouter: viewRouter, store: AppStore.default, shouldShow: $shouldShowTabBar)
            },
            TabBarElement(tabBarElementItem: .init(title: "Third", systemImageName: "folder.fill")) {
                InventoryView(username: store.state.user?.name ?? "",
                              shouldShowTabBar: $shouldShowTabBar,
                              viewRouter: viewRouter)
                    .environmentObject(DerivedGlobalStore.default)
                    .environmentObject(InventoryStore.default)
                    .hideKeyboardOnScroll()
            },
            TabBarElement(tabBarElementItem: .init(title: "Fourth", systemImageName: "message")) {
                ChatView(lastMessageChannelId: $lastMessageChannelId)
                    .withTabViewWrapper(viewRouter: viewRouter, store: DerivedGlobalStore.default, shouldShow: $shouldShowTabBar)
            })
        }
        .onReceive(store.environment.pushNotificationService.lastMessageChannelIdSubject) { lastMessageChannelId in
            self.lastMessageChannelId = lastMessageChannelId
            if lastMessageChannelId != nil && viewRouter.currentPage != .chat {
                viewRouter.currentPage = .chat
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
