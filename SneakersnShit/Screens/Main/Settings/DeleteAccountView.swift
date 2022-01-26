//
//  DeleteAccountView.swift
//  CopDeck
//
//  Created by István Kreisz on 1/25/22.
//

import Foundation
import SwiftUI

struct DeleteAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var loader = Loader()

    @State private var alert: (String, String)? = nil

    var body: some View {
        let presentErrorAlert = Binding<Bool>(get: { alert != nil }, set: { new in alert = new ? alert : nil })

        VStack(spacing: 8) {
            NavigationBar(title: "Delete account", isBackButtonVisible: true, titleFontSize: .large, style: .dark) {
                presentationMode.wrappedValue.dismiss()
            }
            .padding(.top, 30)

            Text("Warning!!! This will delete your entire CopDeck account and all your data associated with it. This is a permanent change and your account cannot be restored once you delete it. If you have an active subscription or trial version, you'll still be able to cancel it from the 'Subscriptions' section of the 'Settings' app after your account has been deleted.")
                .foregroundColor(.customText2)
                .font(.regular(size: 18))
                .multilineTextAlignment(.leading)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: Styles.cornerRadius)
                    .stroke(Color.customRed, lineWidth: 2)
                    .background(Color.customRed.opacity(0.1).cornerRadius(Styles.cornerRadius)))
                .padding(.bottom, 5)
                .layoutPriority(2)

            Button {
                self.alert = ("Are you sure?", "This will delete all your account data and permanently delete your CopDeck account. Click on 'Confirm' to proceed with the deletion.")
            } label: {
                Text("Delete account")
                    .font(.bold(size: 14))
                    .foregroundColor(.customWhite)
                    .frame(width: 150, height: Styles.inputFieldHeight)
                    .background(RoundedRectangle(cornerRadius: Styles.cornerRadius)
                        .fill(Color.customRed))
            }
            .layoutPriority(2)
            
            Spacer()
        }
        .alert(isPresented: presentErrorAlert) {
            let title = alert?.0 ?? ""
            let description = alert?.1 ?? ""
            return Alert(title: Text(title), message: Text(description), primaryButton: .cancel(), secondaryButton: .destructive(Text("Confirm"), action: {
                deleteAccount()
            }))
        }
        .withDefaultPadding(padding: .horizontal)
        .navigationbarHidden()
        .preferredColorScheme(.light)
    }

    private func deleteAccount() {
        AppStore.default.send(.authentication(action: .deleteAccount))
    }
}
