//
//  RootView.swift
//  InfluTrader
//
//  Created by István Kreisz on 1/29/21.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: Store<AppState, AppAction, World>

    @State var userId: String = ""

    var body: some View {
        ZStack {
            if store.state.userIdState.userId.isEmpty {
                LoginView()
                    .environmentObject(store
                                        .derived(deriveState: \.userIdState,
                                 deriveAction: AppAction.authenticator,
                                 derivedEnvironment: store.environment.authentication))
                    .zIndex(1)
            } else {
                MainView()
                    .environmentObject(store
                        .derived(deriveState: \.mainState,
                                 deriveAction: AppAction.function,
                                 derivedEnvironment: store.environment.main))
                    .zIndex(0)
            }
        }
        .onReceive(store.$state) { state in
            if !state.userIdState.userId.isEmpty && self.userId.isEmpty { // when user just logged in
                UIApplication.shared.endEditing()
            }
            self.userId = state.userIdState.userId
        }
//        .alert(isPresented: store.state.errorState.error != nil) {
//            Alert(title: Text(self.appError?.title ?? "Ooops"),
//                  message: Text(self.appError?.message ?? "Unknown Error"),
//                  dismissButton: .default(Text("OK")))
//        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AppStore(initialState: .init(),
                                        reducer: appReducer,
                                        environment: World()))
    }
}
