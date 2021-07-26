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

    var body: some View {
        ZStack {
            switch viewRouter.currentPage {
            case .home:
                Text("Home")
                    .modifier(WrappedMainView(viewRouter: viewRouter))
                    .environmentObject(store)
            case .search:
                SearchView()
                    .modifier(WrappedMainView(viewRouter: viewRouter))
                    .environmentObject(store)
            case .inventory:
                InventoryView()
                    .modifier(WrappedMainView(viewRouter: viewRouter))
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
