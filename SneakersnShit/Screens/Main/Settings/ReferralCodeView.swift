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

    var referralCodeInfo: (code: String, name: String, discount: String)? {
        guard let referralCode = store.globalState.user?.membershipInfo?.referralCodeUsed,
              let referralCodeName = store.globalState.user?.membershipInfo?.referralCodeName,
              let referralCodeDiscount = store.globalState.user?.membershipInfo?.referralCodeDiscount
        else { return nil }
        return (referralCode, referralCodeName, referralCodeDiscount)
    }

    var hasDiscounts: Bool {
        (referralCodeInfo != nil) || (store.globalState.user?.membershipInfo?.isBetaTester == true)
    }
    
    var totalDiscount: String? {
        var discount: Int?
        if let referralCodeInfo = referralCodeInfo {
            discount = Int(referralCodeInfo.discount)
        }
        if store.globalState.user?.membershipInfo?.isBetaTester == true {
            if let d = discount {
                discount = max(DefaultPaymentService.iosBetaTesterDiscount.value, d)
            } else {
                discount = DefaultPaymentService.iosBetaTesterDiscount.value
            }
        }
        return discount.map { "\($0)" }
    }

    var body: some View {
        let presentErrorAlert = Binding<Bool>(get: { error != nil }, set: { new in error = new ? error : nil })

        VStack(spacing: 8) {
            NavigationBar(title: "Referral code", isBackButtonVisible: true, titleFontSize: .large, style: .dark) {
                presentationMode.wrappedValue.dismiss()
            }
            .withDefaultPadding(padding: .top)
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
                        TextFieldRounded(placeHolder: "Enter referral code", style: .gray, text: $referralCode)
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

                if hasDiscounts {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Your discounts:")
                            .foregroundColor(.customText1)
                            .font(.bold(size: 18))
                            .padding(.bottom, 10)

                        if let referralCodeInfo = referralCodeInfo {
                            Text("• Referral code: \(referralCodeInfo.code) (\(referralCodeInfo.name), \(referralCodeInfo.discount)% OFF)")
                                .foregroundColor(.customText1)
                                .font(.regular(size: 15))
                        }
                        if store.globalState.user?.membershipInfo?.isBetaTester == true {
                            Text("• iOS Beta Tester (\(DefaultPaymentService.iosBetaTesterDiscount.valueString)% OFF)")
                                .foregroundColor(.customText1)
                                .font(.regular(size: 15))
                        }
                        if let totalDiscount = totalDiscount {
                            Text("• Total: \(totalDiscount)% OFF")
                                .foregroundColor(.customText1)
                                .font(.bold(size: 15))
                        }
                    }
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: Styles.cornerRadius)
                        .stroke(Color.customBlue, lineWidth: 2)
                        .background(Color.customBlue.opacity(0.1).cornerRadius(Styles.cornerRadius)))
                    .layoutPriority(2)
                }

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
