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
                    .layoutPriority(2)
                HStack(alignment: .center, spacing: 10) {
                    Button(action: {
                        viewRouter.currentPage = .home
                    }) {
                            Image("home")
                                .renderingMode(.template)
                                .frame(height: 24)
                                .foregroundColor(viewRouter.currentPage == .home ? .customText1 : .customAccent1)
                                .centeredHorizontally()
                    }
                    .frame(width: 82)
                    Button(action: {
                        viewRouter.currentPage = .search
                    }) {
                            Image("search")
                                .renderingMode(.template)
                                .frame(height: 24)
                                .foregroundColor(viewRouter.currentPage == .search ? .customText1 : .customAccent1)
                                .centeredHorizontally()
                    }
                    .frame(width: 82)
                    Button(action: {
                        viewRouter.currentPage = .inventory
                    }) {
                            Image("inventory")
                                .renderingMode(.template)
                                .frame(height: 24)
                                .foregroundColor(viewRouter.currentPage == .inventory ? .customText1 : .customAccent1)
                                .centeredHorizontally()
                    }
                    .frame(width: 82)
                }
                .frame(width: 246, height: 60)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
                .layoutPriority(2)
                Spacer(minLength: 35)
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
