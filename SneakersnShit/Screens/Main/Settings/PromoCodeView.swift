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
        let presentErrorAlert = Binding<Bool>(get: { error != nil }, set: { new in error = new ? error : nil })

        VStack(spacing: 8) {
            NavigationBar(title: "Promo code", isBackButtonVisible: true, titleFontSize: .large, style: .dark) {
                presentationMode.wrappedValue.dismiss()
            }
            .withDefaultPadding(padding: .top)
            VStack(alignment: .leading, spacing: 12) {
                Text("1. Use your promo code to get a discount on subscription fees.")
                    .foregroundColor(.customText2)
                    .font(.regular(size: 18))
                    .multilineTextAlignment(.leading)
                Text("2. Paste your promo code in the field below and tap \"Send\".")
                    .foregroundColor(.customText2)
                    .font(.regular(size: 18))
                    .multilineTextAlignment(.leading)
                Text("3. You can only use one promo code per account and you can't change it once you've added one.")
                    .foregroundColor(.customText2)
                    .font(.regular(size: 18))
                    .multilineTextAlignment(.leading)
            }
            .padding(.bottom, 8)
            VStack(spacing: 20) {
                if loader.isLoading {
                    CustomSpinner(text: "Updating account", animate: true)
                }

                if let promoCode = store.globalState.user?.membershipInfo?.promoCodeUsed {
                    HStack(spacing: 5) {
                        Text("Your promo code:")
                            .foregroundColor(.customText2)
                            .font(.regular(size: 18))
                        Text(promoCode)
                            .foregroundColor(.customBlue)
                            .font(.bold(size: 20))
                        Spacer()
                    }
                    .padding(.top, 5)
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
                            Text("Send")
                                .font(.bold(size: 14))
                                .foregroundColor(.customWhite)
                                .frame(width: 80, height: Styles.inputFieldHeight)
                                .background(RoundedRectangle(cornerRadius: Styles.cornerRadius)
                                    .fill(Color.customBlue))
                        }
                    }
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
    }

    private func applyPromoCode(_ promoCode: String) {
        guard !promoCode.isEmpty else {
            self.error = ("Error", "Invalid Promo code")
            return
        }
        let loader = loader.getLoader()
        store.send(.paymentAction(action: .applyPromoCode(promoCode, completion: { result in
            if case let .failure(error) = result {
                self.error = ("Error", error.localizedDescription)
            }
            loader(.success(()))
        })))
    }
}
