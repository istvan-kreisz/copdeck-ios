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
    @StateObject var viewRouter = ViewRouter()

    @State var shouldShowTabBar = true

    var body: some View {
        let selectedIndex = Binding<Int>(get: { viewRouter.currentPage.rawValue }, set: { viewRouter.currentPage = Page(rawValue: $0) ?? .search })
        UITabBarWrapper(selectedIndex: selectedIndex) {
            (TabBarElement(tabBarElementItem: .init(title: "First", systemImageName: "house.fill")) {
                FeedView(userId: store.state.user?.id ?? "")
                    .withTabViewWrapper(viewRouter: viewRouter, store: FeedStore.default, shouldShow: $shouldShowTabBar)
            },
            TabBarElement(tabBarElementItem: .init(title: "Second", systemImageName: "pencil.circle.fill")) {
                SearchView()
                    .withTabViewWrapper(viewRouter: viewRouter, store: SearchStore.default, shouldShow: $shouldShowTabBar)
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
                ChatView()
                    .withTabViewWrapper(viewRouter: viewRouter, store: DerivedGlobalStore.default, shouldShow: $shouldShowTabBar)
            })
        }
        .edgesIgnoringSafeArea(.all)
    }
}
