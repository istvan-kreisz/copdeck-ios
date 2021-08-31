//
//  Main.swift
//  CopDeck
//
//  Created by István Kreisz on 1/28/21.
//

import SwiftUI
import FirebaseFunctions

struct MainContainerView: View {
    @EnvironmentObject var store: AppStore
    @StateObject var viewRouter = ViewRouter()

    @State var shouldShowTabBar = true
    @State var settingsPresented = false

    var body: some View {
        UITabBarWrapper(selectedIndex: $viewRouter.currentPage) {
            (TabBarElement(tabBarElementItem: .init(title: "First", systemImageName: "house.fill")) {
                FeedView()
                    .withTabViewWrapper(viewRouter: viewRouter, store: store, shouldShow: $shouldShowTabBar)
            },
            TabBarElement(tabBarElementItem: .init(title: "Second", systemImageName: "pencil.circle.fill")) {
                SearchView()
                    .withTabViewWrapper(viewRouter: viewRouter, store: store, shouldShow: $shouldShowTabBar)
            },
            TabBarElement(tabBarElementItem: .init(title: "Third", systemImageName: "folder.fill")) {
                InventoryView(username: store.state.user?.name ?? "",
                              shouldShowTabBar: $shouldShowTabBar,
                              settingsPresented: $settingsPresented,
                              viewRouter: viewRouter)
                    .environmentObject(store)
            })
        }
        .hideKeyboardOnScroll()
        .edgesIgnoringSafeArea(.all)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        return
            MainContainerView()
                .environmentObject(AppStore.default)
    }
}
