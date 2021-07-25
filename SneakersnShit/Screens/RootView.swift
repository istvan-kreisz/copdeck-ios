//
//  RootView.swift
//  CopDeck
//
//  Created by István Kreisz on 1/29/21.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: AppStore

    class ViewState {
        var firstShow = true
    }

    var viewState = ViewState()

    var body: some View {
        let presentErrorAlert = Binding<Bool>(get: { store.state.error != nil }, set: { _ in })
        ZStack {
            if store.state.firstLoadDone {
                if store.state.user?.id.isEmpty ?? true {
                    LoginView()
                        .environmentObject(store)
                        .zIndex(1)
                } else {
                    MainView()
                        .environmentObject(store)
                        .zIndex(0)
                }
            } else {
                Text("splashscreen")
            }
        }
        .onReceive(store.$state) { state in
            // user just logged in
            if (state.user != nil) {
                UIApplication.shared.endEditing()
            }
        }
        .alert(isPresented: presentErrorAlert) {
            Alert(title: Text((store.state.error?.title) ?? "Ooops"),
                  message: Text((store.state.error?.message) ?? "Unknown Error"),
                  dismissButton: .default(Text("OK")))
        }
        .onAppear {
            if viewState.firstShow {
                viewState.firstShow = false
                store.send(.authentication(action: .restoreState))
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AppStore.default)
    }
}
