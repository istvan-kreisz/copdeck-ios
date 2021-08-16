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
//        let presentStockXFeeUpdateAlert = Binding<Bool>(get: {
//                                                            !UserDefaults.standard.bool(forKey: "hasShownStockxAug2021UpdateAlert")
//        },
//                                                        set: { new in
//                                                            if !new {
//                                                                UserDefaults.standard.set(true, forKey: "hasShownStockxAug2021UpdateAlert")
//                                                            }
//                                                        })
        ZStack {
            switch viewRouter.currentPage {
            case .home:
                EmptyView()
//                FeedView()
//                    .withTabViewWrapper(viewRouter: viewRouter, store: store, shouldShow: $shouldShowTabBar)
            case .search:
                SearchView()
                    .withTabViewWrapper(viewRouter: viewRouter, store: store, shouldShow: $shouldShowTabBar)
            case .inventory:
                EmptyView()
//                InventoryView(shouldShowTabBar: $shouldShowTabBar, settingsPresented: $settingsPresented, viewRouter: viewRouter)
//                    .withTabViewWrapper(viewRouter: viewRouter, store: store, shouldShow: $shouldShowTabBar)
//                    .environmentObject(store)
            }
        }
        .hideKeyboardOnScroll()


//        .alert(isPresented: presentStockXFeeUpdateAlert) {
//            Alert(title: Text("Update your seller / buyer stats"),
//                  message: Text("In order to get accurate results for buyer & seller price calculation, you must update your StockX / GOAT / Klekt seller & buyer stats"),
//                  primaryButton: .default(Text("I'll do it later"), action: {}),
//                  secondaryButton: .default(Text("Take me to Settings"), action: {
//                      viewRouter.currentPage = .inventory
//                      settingsPresented = true
//                  }))
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
