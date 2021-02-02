//
//  RootView.swift
//  InfluTrader
//
//  Created by István Kreisz on 1/29/21.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: Store<AppState, AppAction, World>

    @State var errorShown = false
    @State var appError: AppError?
    @State var userId: String = ""

    var body: some View {
        Text("")
//        Group {
//            if store.state.userState.userId.isEmpty {
//                LoginView()
//                    .environmentObject(store
//                        .derived(deriveState: \.userState,
//                                 deriveAction: AppAction.authenticator,
//                                 derivedEnvironment: store.environment.authentication))
//                    .zIndex(1)
//            } else {
//                MainView()
//                    .environmentObject(store
//                        .derived(deriveState: \.mainState,
//                                 deriveAction: AppAction.function,
//                                 derivedEnvironment: store.environment.main))
//                    .zIndex(0)
//            }
//        }
//        .onReceive(store.$state) { state in
//            if !state.userState.userId.isEmpty && self.userId.isEmpty { // when user just logged in
//                UIApplication.shared.endEditing()
//            }
//            self.userId = state.userState.userId
////            if let error = state.errorState.error {
////                if self.appError?.id != error.id {
////                    self.appError = state.error
////                    self.errorShown = true
////                }
////            }
//        }
//        .alert(isPresented: $errorShown) {
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
