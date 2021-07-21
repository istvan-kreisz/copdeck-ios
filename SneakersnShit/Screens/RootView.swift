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

    class ViewState {
        var firstShow = true
    }

    var viewState = ViewState()

    #warning("refactor")

    var body: some View {
        let presentErrorAlert = Binding<Bool>(get: { store.state.error != nil }, set: { _ in })
        ZStack {
            if let userId = store.state.userId {
                if userId.isEmpty {
                    LoginView()
                        .environmentObject(store)
                        .zIndex(1)
                } else {
                    MainView()
                        .environmentObject(store)
                        .zIndex(0)
                }
            } else {
                Text("Splashscreen")
            }
        }
        .onReceive(store.$state) { state in
            if (state.userId?.isEmpty == false) && (userId == nil || userId?.isEmpty == true) {
                // user just logged in
                UIApplication.shared.endEditing()
            }
            userId = state.userId
        }
        .alert(isPresented: presentErrorAlert) {
            Alert(title: Text(store.state.error?.title ?? "Ooops"),
                  message: Text(store.state.error?.message ?? "Unknown Error"),
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
