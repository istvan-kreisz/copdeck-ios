//
//  RootView.swift
//  CopDeck
//
//  Created by István Kreisz on 1/29/21.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: AppStore
    @State var user: User?
    @StateObject var viewState = ViewState()

    class ViewState: ObservableObject {
        @Published var firstShow = true
    }

    var body: some View {
        let presentErrorAlert = Binding<Bool>(get: {
                                                  store.state.error != nil
                                                      && (store.state.error?.title.isEmpty == false ||
                                                          store.state.error?.message.isEmpty == false)
                                              },
                                              set: { _ in })
        ZStack {
            if store.state.firstLoadDone {
                if store.state.user?.id.isEmpty ?? true {
                    LoginView()
                        .environmentObject(store)
                        .zIndex(1)
                } else {
                    if user?.inited != true {
                        CountrySelector(settings: store.state.settings)
                    } else {
                        MainContainerView()
                            .environmentObject(store)
                            .zIndex(0)
                    }
                }
            } else {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 130)
                    .centeredVertically()
                    .centeredHorizontally()
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .onReceive(store.$state) { state in
            // user just logged in
            if state.user != nil && user == nil {
                UIApplication.shared.endEditing()
            } else if state.user == nil {
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
            }
            user = state.user
        }
        .alert(isPresented: presentErrorAlert) {
            Alert(title: Text((store.state.error?.title) ?? "Ooops"),
                  message: Text((store.state.error?.message) ?? "Unknown Error"),
                  dismissButton: .default(Text("OK")))
        }
        .onAppear { [weak viewState] in
            guard let viewState = viewState else { return }
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
