//
//  ReferralCodeView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/29/21.
//

import SwiftUI

struct ReferralCodeView: View {
    @EnvironmentObject var store: DerivedGlobalStore
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var loader = Loader()

    @State private var error: (String, String)? = nil
    @State var referralCode = ""

    var body: some View {
        let presentErrorAlert = Binding<Bool>(get: { error != nil }, set: { new in error = new ? error : nil })

        VStack(spacing: 8) {
            NavigationBar(title: "Referral code", isBackButtonVisible: true, titleFontSize: .large, style: .dark) {
                presentationMode.wrappedValue.dismiss()
            }
            .padding(.top, 30)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("1. Use a referral code to get a discount on subscription fees.")
                    .foregroundColor(.customText2)
                    .font(.regular(size: 18))
                    .multilineTextAlignment(.leading)
                Text("2. Paste your referral code in the field below and tap \"Send\".")
                    .foregroundColor(.customText2)
                    .font(.regular(size: 18))
                    .multilineTextAlignment(.leading)
                Text("3. You can only use one referral code per account and you can't change it once you've added one.")
                    .foregroundColor(.customText2)
                    .font(.regular(size: 18))
                    .multilineTextAlignment(.leading)
            }
            .padding(.bottom, 8)
            .layoutPriority(2)
            VStack(spacing: 20) {
                if loader.isLoading {
                    CustomSpinner(text: "Updating account", animate: true)
                }

                if store.globalState.user?.membershipInfo?.referralCodeUsed == nil {
                    HStack(spacing: 5) {
                        TextFieldRounded(placeHolder: "Enter referral code", style: .gray, text: $referralCode, addClearButton: true)
                            .layoutPriority(1)
                        Button {
                            if let referralCode = store.globalState.user?.membershipInfo?.referralCodeUsed {
                                self.error = ("Error", "Your account already has the \"\(referralCode)\" referral code associated with it.")
                            } else {
                                applyReferralCode(referralCode)
                            }
                        } label: {
                            Text("Send")
                                .font(.bold(size: 14))
                                .foregroundColor(.customWhite)
                                .frame(width: 80, height: Styles.inputFieldHeight)
                                .background(RoundedRectangle(cornerRadius: Styles.cornerRadius)
                                    .fill(Color.customBlue))
                        }
                    }
                    .layoutPriority(2)
                }

                DiscountsView(membershipInfo: store.globalState.user?.membershipInfo)

                Spacer()
            }
        }
        .withDefaultPadding(padding: .horizontal)
        .alert(isPresented: presentErrorAlert) {
            let title = error?.0 ?? ""
            let description = error?.1 ?? ""
            return Alert(title: Text(title), message: Text(description), dismissButton: Alert.Button.cancel(Text("Okay")))
        }
        .navigationbarHidden()
        .preferredColorScheme(.light)
    }

    private func applyReferralCode(_ referralCode: String) {
        guard !referralCode.isEmpty else {
            self.error = ("Error", "Invalid Promo code")
            return
        }
        let loader = loader.getLoader()
        store.send(.paymentAction(action: .applyReferralCode(referralCode, completion: { result in
            if case let .failure(error) = result {
                self.error = ("Error", error.localizedDescription)
            }
            loader(.success(()))
        })))
    }
}
