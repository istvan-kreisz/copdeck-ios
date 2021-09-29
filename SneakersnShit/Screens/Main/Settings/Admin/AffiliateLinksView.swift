//
//  AffiliateLinksView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/29/21.
//

import SwiftUI

#warning("hide email?")

struct AffiliateLinksView: View {
    @EnvironmentObject var store: DerivedGlobalStore
    @Environment(\.presentationMode) var presentationMode
    @State var promoters: [User] = []
    @State private var error: (String, String)? = nil

    @StateObject private var loader = Loader()

    var body: some View {
        let presentErrorAlert = Binding<Bool>(get: { error != nil }, set: { new in error = new ? error : nil })

        VStack(spacing: 8) {
            NavigationBar(title: nil, isBackButtonVisible: true, style: .dark) {
                presentationMode.wrappedValue.dismiss()
            }
            .withDefaultPadding(padding: .top)
            .withDefaultPadding(padding: .horizontal)

            Text("Affiliate links dashboard")
                .foregroundColor(.customText1)
                .font(.bold(size: 22))
                .padding(.bottom, 25)

            List {
                if loader.isLoading {
                    CustomSpinner(text: "Loading", animate: true)
                }

                ForEach(promoters) { (user: User) in
                    VStack(spacing: 10) {
                        if let username = user.name {
                            UserDetailView(name: "username", value: username, showCopyButton: false)
                        }
                        UserDetailView(name: "userid", value: user.id, showCopyButton: false)
                        UserDetailView(name: "email", value: user.email ?? "-")
                        if let promoCode = user.affiliateData?.promoCode {
                            UserDetailView(name: "promo code", value: promoCode)
                        }
                        if let invitesSignedUp = user.affiliateData?.invitesSignedUp {
                            UserDetailView(name: "invite count (signed up)", value: "\(invitesSignedUp)", showCopyButton: false)
                        }
                        if let invitesSubscribed = user.affiliateData?.invitesSubscribed {
                            UserDetailView(name: "invite count (subscribed)", value: "\(invitesSubscribed)", showCopyButton: false)
                        }
                    }
                    .padding(.vertical, 5)
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .onAppear {
            refreshList()
        }
        .alert(isPresented: presentErrorAlert) {
            let title = error?.0 ?? ""
            let description = error?.1 ?? ""
            return Alert(title: Text(title), message: Text(description), dismissButton: Alert.Button.cancel(Text("Okay")))
        }
        .navigationbarHidden()
    }

    private func refreshList() {
        let loader = loader.getLoader()
        store.send(.main(action: .getAffiliateList(completion: { result in
            switch result {
            case let .success(users):
                promoters = users
            case let .failure(error):
                self.error = ("Error", error.localizedDescription)
            }
            loader(.success(()))

        })))
    }
}
