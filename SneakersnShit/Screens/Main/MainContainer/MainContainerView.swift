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
        ZStack { [weak viewRouter] in
            if let viewRouter = viewRouter {
                switch viewRouter.currentPage {
                case .home:
                    FeedView()
                        .withTabViewWrapper(viewRouter: viewRouter, store: store, shouldShow: $shouldShowTabBar)
                case .search:
                    SearchView()
                        .withTabViewWrapper(viewRouter: viewRouter, store: store, shouldShow: $shouldShowTabBar)
                case .inventory:
                    InventoryView(shouldShowTabBar: $shouldShowTabBar, settingsPresented: $settingsPresented, viewRouter: viewRouter)
                        .withTabViewWrapper(viewRouter: viewRouter, store: store, shouldShow: $shouldShowTabBar)
                        .environmentObject(store)
                }
            }
        }
        .hideKeyboardOnScroll()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        return
            MainContainerView()
                .environmentObject(AppStore.default)
    }
}
