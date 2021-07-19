//
//  RootView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/29/21.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: AppStore

    @State var userId: String?

    #warning("refactor")

    var body: some View {
        let presentErrorAlert = Binding<Bool>(get: { store.state.errorState.error != nil }, set: { _ in })
        ZStack {
            if let userId = store.state.authenticationState.userId {
                if userId.isEmpty {
                    LoginView()
                        .environmentObject(store
                            .derived(deriveState: \.authenticationState,
                                     deriveAction: AppAction.authenticator,
                                     derivedEnvironment: store.environment.authentication))
                        .zIndex(1)
                } else {
                    if store.state.mainState.userId.isEmpty {
                        Text("Splashscreen")
                    } else {
                        MainView()
                            .environmentObject(store
                                .derived(deriveState: \.mainState,
                                         deriveAction: AppAction.main,
                                         derivedEnvironment: store.environment.main))
                            .zIndex(0)
                    }
                }
            } else {
                Text("Splashscreen")
            }
        }
        .onReceive(store.$state) { state in
            if (state.authenticationState.userId?.isEmpty == false) && (userId == nil || userId?.isEmpty == true) {
                // user just logged in
                UIApplication.shared.endEditing()
            }
            userId = state.authenticationState.userId
        }
        .alert(isPresented: presentErrorAlert) {
            Alert(title: Text(store.state.errorState.error?.title ?? "Ooops"),
                  message: Text(store.state.errorState.error?.message ?? "Unknown Error"),
                  dismissButton: .default(Text("OK")))
        }
        .onAppear {
            store.send(.authenticator(action: .restoreState))
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AppStore(initialState: .mockAppState,
                                        reducer: appReducer,
                                        environment: World(isMockInstance: true)))
    }
}
