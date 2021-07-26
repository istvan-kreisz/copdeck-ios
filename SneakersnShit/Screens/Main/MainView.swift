//
//  Main.swift
//  CopDeck
//
//  Created by István Kreisz on 1/28/21.
//

import SwiftUI
import FirebaseFunctions

struct MainView: View {
    @EnvironmentObject var store: AppStore
    @StateObject var viewRouter = ViewRouter()

    @State var shouldShowTabBar = true

    var body: some View {
        ZStack {
            switch viewRouter.currentPage {
            case .home:
                Text("Home")
                    .withTabViewWrapper(viewRouter: viewRouter, store: store, shouldShow: $shouldShowTabBar)
            case .search:
                SearchView()
                    .withTabViewWrapper(viewRouter: viewRouter, store: store, shouldShow: $shouldShowTabBar)
            case .inventory:
                InventoryView(shouldShowTabBar: $shouldShowTabBar)
                    .withTabViewWrapper(viewRouter: viewRouter, store: store, shouldShow: $shouldShowTabBar)
            }
        }
        .hideKeyboardOnScroll()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        return
            MainView()
                .environmentObject(AppStore.default)
    }
}
