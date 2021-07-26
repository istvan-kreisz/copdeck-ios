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
                    .modifier(WrappedMainView(viewRouter: viewRouter, shouldShow: $shouldShowTabBar))
                    .environmentObject(store)
            case .search:
                SearchView()
                    .modifier(WrappedMainView(viewRouter: viewRouter, shouldShow: $shouldShowTabBar))
                    .environmentObject(store)
            case .inventory:
                InventoryView(shouldShowTabBar: $shouldShowTabBar)
                    .modifier(WrappedMainView(viewRouter: viewRouter, shouldShow: $shouldShowTabBar))
                    .environmentObject(store)
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
