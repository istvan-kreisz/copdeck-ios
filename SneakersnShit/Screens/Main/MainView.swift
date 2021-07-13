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
                    Text("Inventory")
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
