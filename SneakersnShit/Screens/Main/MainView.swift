//
//  Main.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/28/21.
//

import SwiftUI
import FirebaseFunctions

struct MainView: View {
    @EnvironmentObject var store: MainStore
    @StateObject var viewRouter = ViewRouter()

    var body: some View {
        ZStack {
            switch viewRouter.currentPage {
            case .home:
                NavigationView {
                    Text("Home")
                }
            case .search:
                NavigationView {
                    SearchView()
                        .environmentObject(store)
                }
            case .inventory:
                NavigationView {
                    Text("Inventory")
                }
            }
            VStack {
                Spacer()
                HStack(alignment: .center, spacing: 10) {
                    Button("Home") {
                        viewRouter.currentPage = .home
                    }
                    Button("Search") {
                        viewRouter.currentPage = .search
                    }
                    Button("Inventory") {
                        viewRouter.currentPage = .inventory
                    }
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let store = AppStore(initialState: .mockAppState,
                             reducer: appReducer,
                             environment: World(isMockInstance: true))
        return
            MainView()
                .environmentObject(store
                    .derived(deriveState: \.mainState,
                             deriveAction: AppAction.main,
                             derivedEnvironment: store.environment.main))
    }
}
