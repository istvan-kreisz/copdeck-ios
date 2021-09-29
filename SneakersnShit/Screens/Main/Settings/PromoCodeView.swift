//
//  PromoCodeView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/29/21.
//

import SwiftUI

struct PromoCodeView: View {
    @EnvironmentObject var store: DerivedGlobalStore
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var loader = Loader()

    @State private var error: (String, String)? = nil
    @State var promoCode = ""

    var body: some View {
        VStack(spacing: 8) {
            NavigationBar(title: "Apply promo code", isBackButtonVisible: true, style: .dark) {
                presentationMode.wrappedValue.dismiss()
            }
            .withDefaultPadding(padding: .top)
            Text("""
            • Use your promo code to get a discount on subscription fees.
            • Paste your promo code in the field below and tap "Send".
            • You can only use one promo code per account and you can't change it once you've applied one.
            """)
                .foregroundColor(.customText2)
                .font(.regular(size: 15))
                .multilineTextAlignment(.center)
            Spacer()
            VStack(spacing: 20) {
                if loader.isLoading {
                    CustomSpinner(text: "Updating account", animate: true)
                }

                if let promoCode = store.globalState.user?.membershipInfo?.promoCodeUsed {
                    HStack(spacing: 5) {
                        Text("Your promo code:")
                            .foregroundColor(.customText2)
                            .font(.regular(size: 14))
                        Text(promoCode)
                            .foregroundColor(.customBlue)
                            .font(.bold(size: 14))
                        Spacer()
                    }
                } else {
                    HStack(spacing: 5) {
                        TextFieldRounded(placeHolder: "Enter promo code", style: .gray, text: $promoCode)
                            .layoutPriority(1)
                        Button {
                            if let promoCode = store.globalState.user?.membershipInfo?.promoCodeUsed {
                                self.error = ("Error", "You've already applied the promo code: \(promoCode).")
                            } else {
                                applyPromoCode(promoCode)
                            }
                        } label: {
                            Text("Start import")
                                .font(.bold(size: 14))
                                .foregroundColor(.customWhite)
                                .frame(width: 110, height: Styles.inputFieldHeight)
                                .background(RoundedRectangle(cornerRadius: Styles.cornerRadius)
                                    .fill(Color.customBlue))
                        }
                    }
                }
            }
        }
        .withDefaultPadding(padding: .horizontal)
        .navigationbarHidden()
    }

    private func applyPromoCode(_ promoCode: String) {
        let loader = loader.getLoader()
        store.send(.paymentAction(action: .applyPromoCode(promoCode, completion: { result in
            if case let .failure(error) = result {
                self.error = ("Error", error.localizedDescription)
            }
            loader(.success(()))
        })))
    }
}
