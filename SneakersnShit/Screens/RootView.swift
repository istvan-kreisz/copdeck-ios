//
//  RootView.swift
//  CopDeck
//
//  Created by István Kreisz on 1/29/21.
//

import SwiftUI

struct RootView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var store: AppStore
    @State var user: User?

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
            if (state.user != nil && user == nil) {
                user = state.user
                UIApplication.shared.endEditing()
            } else if state.user == nil {
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
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
        .preferredColorScheme(.light)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AppStore.default)
    }
}
