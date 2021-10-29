//
//  RootView.swift
//  CopDeck
//
//  Created by István Kreisz on 1/29/21.
//

import SwiftUI
import Purchases

struct RootView: View {
    @EnvironmentObject var store: DerivedGlobalStore
    @State var user: User?
    @StateObject var viewState = ViewState()

    @State private var error: (String, String)? = nil
    @State private var showPayment1View = true

    @AppStorage(UserDefaults.Keys.needsAppOnboarding.rawValue) private var needsAppOnboarding: Bool = true

    class ViewState: ObservableObject {
        @Published var firstShow = true
    }

    var body: some View {
        let presentErrorAlert = Binding<Bool>(get: { error != nil }, set: { new in error = new ? error : nil })
        ZStack {
            if store.globalState.firstLoadDone && store.globalState.didFetchPurchaserInfo {
                if store.globalState.user?.id.isEmpty ?? true {
                    LoginView()
                        .zIndex(1)
                        .onAppear { showPayment1View = true }
                } else {
                    if needsAppOnboarding {
                        RootOnboardingView()
                    } else if user?.inited != true {
                        CountrySelector(settings: store.globalState.settings)
                    } else {
                        if let monthlyPackage = store.globalState.packages?.monthlyPackage,
                           Purchases.shared.appUserID.contains("RCAnonymousID") == false,
                           !store.globalState.hasSubscribed,
                           showPayment1View,
                            DebugSettings.shared.isPaywallEnabled {
                            PaymentView(viewType: .trial(monthlyPackage)) { showPayment1View = false }
                        } else {
                            ZStack {
                                MainContainerView(store: store.appStore)
                                    .zIndex(0)
                                if store.globalState.showPaymentView && DebugSettings.shared.isPaywallEnabled {
                                    PaymentView(viewType: .subscribe)  { store.send(.paymentAction(action: .showPaymentView(show: false))) }
                                }
                            }
                        }
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
        .onReceive(store.$globalState) { state in
            // user just logged in
            if state.user != nil && user == nil {
                UIApplication.shared.endEditing()
            } else if state.user == nil {
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
            }
            if user != state.user {
                user = state.user
            }
        }
        .onChange(of: store.globalState.error) { error in
            if let title = error?.title, let message = error?.message {
                self.error = (title, message)
            }
        }
        .alert(isPresented: presentErrorAlert) {
            Alert(title: Text(error?.0 ?? "Ooops"), message: Text(error?.1 ?? "Unknown Error"), dismissButton: .default(Text("OK")))
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
