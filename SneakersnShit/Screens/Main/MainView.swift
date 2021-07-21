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

    @State private var hasPushedView = false

    var body: some View {
        ZStack {
            switch viewRouter.currentPage {
            case .home:
                NavigationView {
                    Text("Home")
                }
            case .search:
                NavigationView {
                    SearchView(hasPushedView: $hasPushedView)
                        .environmentObject(store)
                }
            case .inventory:
                NavigationView {
                    InventoryView()
                        .environmentObject(store)
                }
            }
            TabBar(viewRouter: viewRouter)
                .if(hasPushedView) {
                    $0.hidden()
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        return
            MainView()
                .environmentObject(AppStore.default)
    }
}
