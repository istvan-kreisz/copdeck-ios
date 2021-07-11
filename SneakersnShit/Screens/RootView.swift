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

    var body: some View {
        ZStack {
//            if let userId = store.state.authenticationState.userId {
//                if userId.isEmpty {
//                    LoginView()
//                        .environmentObject(store
//                            .derived(deriveState: \.authenticationState,
//                                     deriveAction: AppAction.authenticator,
//                                     derivedEnvironment: store.environment.authentication))
//                        .zIndex(1)
//                } else {
//                    if store.state.mainState.userId.isEmpty {
//                        Text("Splashscreen")
//                    } else {
                        MainView()
                            .environmentObject(store
                                .derived(deriveState: \.mainState,
                                         deriveAction: AppAction.main,
                                         derivedEnvironment: store.environment.main))
                            .zIndex(0)
                            .background(Color.customBackground)
//                    }
//                }
//            } else {
//                Text("Splashscreen")
//            }
        }
        .onReceive(store.$state) { state in
//            if (state.authenticationState.userId?.isEmpty == false) && (self.userId == nil || self.userId?.isEmpty == true) {
//                // user just logged in
//                UIApplication.shared.endEditing()
//            }
            self.userId = state.authenticationState.userId
        }
//        .alert(isPresented: store.state.errorState.error != nil) {
//            Alert(title: Text(self.appError?.title ?? "Ooops"),
//                  message: Text(self.appError?.message ?? "Unknown Error"),
//                  dismissButton: .default(Text("OK")))
//        }
        .onAppear {
//            store.send(.authenticator(action: .restoreState))
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
