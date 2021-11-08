//
//  ReferralCodeAdminView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/29/21.
//

import SwiftUI

struct ReferralCodeAdminView: View {
    @EnvironmentObject var store: DerivedGlobalStore
    @Environment(\.presentationMode) var presentationMode
    @State var referralCodes: [ReferralCode] = []
    @State private var error: (String, String)? = nil

    @StateObject private var loader = Loader()

    var body: some View {
        let presentErrorAlert = Binding<Bool>(get: { error != nil }, set: { new in error = new ? error : nil })

        VStack(spacing: 8) {
            NavigationBar(title: nil, isBackButtonVisible: true, style: .dark) {
                presentationMode.wrappedValue.dismiss()
            }
            .padding(.top, 30)
            .withDefaultPadding(padding: .horizontal)

            Text("Affiliate links dashboard")
                .foregroundColor(.customText1)
                .font(.bold(size: 22))
                .padding(.bottom, 25)

            List {
                if loader.isLoading {
                    CustomSpinner(text: "Loading", animate: true)
                }

                ForEach(referralCodes) { (referralCode: ReferralCode) in
                    VStack(spacing: 10) {
                        UserDetailView(name: "code", value: referralCode.code)
                        if let name = referralCode.name {
                            UserDetailView(name: "name", value: name, showCopyButton: false)
                        }

                        UserDetailView(name: "invite count (signed up)", value: "\(referralCode.signedUp?.count ?? 0)", showCopyButton: false)
                        UserDetailView(name: "invite count (subscribed)", value: "\(referralCode.subscribed?.count ?? 0)", showCopyButton: false)
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
            case let .success(referralCodes):
                self.referralCodes = referralCodes
            case let .failure(error):
                self.error = ("Error", error.localizedDescription)
            }
            loader(.success(()))

        })))
    }
}
