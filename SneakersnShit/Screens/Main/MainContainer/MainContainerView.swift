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
        UITabBarWrapper([
            TabBarElement(tabBarElementItem: .init(title: "First", systemImageName: "house.fill")) {
            FeedView()
                .withTabViewWrapper(viewRouter: viewRouter, store: store, shouldShow: $shouldShowTabBar)
                .tag(Page.home)
            },
            TabBarElement(tabBarElementItem: .init(title: "Second", systemImageName: "pencil.circle.fill")) {
                SearchView()
                    .withTabViewWrapper(viewRouter: viewRouter, store: store, shouldShow: $shouldShowTabBar)
                    .tag(Page.search)
            },
            TabBarElement(tabBarElementItem: .init(title: "Third", systemImageName: "folder.fill")) {
                InventoryView(shouldShowTabBar: $shouldShowTabBar, settingsPresented: $settingsPresented, viewRouter: viewRouter)
                    .tag(Page.inventory)
            },
        ])

//        TabView(selection: $viewRouter.currentPage) {
//            FeedView()
//                .withTabViewWrapper(viewRouter: viewRouter, store: store, shouldShow: $shouldShowTabBar)
//                .tag(Page.home)
//            SearchView()
//                .withTabViewWrapper(viewRouter: viewRouter, store: store, shouldShow: $shouldShowTabBar)
//                .tag(Page.search)
//            InventoryView(shouldShowTabBar: $shouldShowTabBar, settingsPresented: $settingsPresented, viewRouter: viewRouter)
//                .tag(Page.inventory)
//        }
//        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//        .hideKeyboardOnScroll()
//        ZStack { [weak viewRouter] in
//            if let viewRouter = viewRouter {
//                FeedView()
//                    .withTabViewWrapper(viewRouter: viewRouter, store: store, shouldShow: $shouldShowTabBar)
//                    .if(viewRouter.currentPage != .home) { $0.hidden() }
//                SearchView()
//                    .withTabViewWrapper(viewRouter: viewRouter, store: store, shouldShow: $shouldShowTabBar)
//                    .if(viewRouter.currentPage != .search) { $0.hidden() }
//                InventoryView(shouldShowTabBar: $shouldShowTabBar, settingsPresented: $settingsPresented, viewRouter: viewRouter)
//                    .withTabViewWrapper(viewRouter: viewRouter, store: store, shouldShow: $shouldShowTabBar)
//                    .if(viewRouter.currentPage != .inventory) { $0.hidden() }
//            }
//        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        return
            MainContainerView()
                .environmentObject(AppStore.default)
    }
}
