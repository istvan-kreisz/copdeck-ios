//
//  ContactView.swift
//  CopDeck
//
//  Created by István Kreisz on 10/19/21.
//

import Foundation
import SwiftUI

struct ContactView: View {
    @EnvironmentObject var store: DerivedGlobalStore
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var loader = Loader()

    @State private var alert: (String, String)? = nil

    @State var email = ""
    @State var message: String?
    @State var didFinishLoading = false

    var body: some View {
        let presentErrorAlert = Binding<Bool>(get: { alert != nil }, set: { new in alert = new ? alert : nil })

        VStack(spacing: 8) {
            NavigationBar(title: "Send us a message", isBackButtonVisible: true, titleFontSize: .large, style: .dark) {
                presentationMode.wrappedValue.dismiss()
            }
            .withDefaultPadding(padding: .top)
            VStack(alignment: .leading, spacing: 12) {
                TextFieldRounded(placeHolder: "Enter your email", style: .gray, text: $email)
                    .layoutPriority(1)
                TextFieldRoundedLarge(placeHolder: "Enter your message", style: .gray, text: $message)
                    .layoutPriority(1)

                Button {
                    sendMessage()
                } label: {
                    Text("Send message")
                        .font(.bold(size: 14))
                        .foregroundColor(.customWhite)
                        .frame(width: UIScreen.screenWidth - Styles.horizontalMargin * 2, height: Styles.inputFieldHeight)
                        .background(RoundedRectangle(cornerRadius: Styles.cornerRadius)
                            .fill(Color.customBlue))
                }
                if loader.isLoading {
                    CustomSpinner(text: "Sending message", animate: true)
                }
                Spacer()
            }
        }
        .alert(isPresented: presentErrorAlert) {
            let title = alert?.0 ?? ""
            let description = alert?.1 ?? ""
            return Alert(title: Text(title), message: Text(description), dismissButton: Alert.Button.cancel(Text("Okay")))
        }
        .onAppear {
            if email.isEmpty {
                email = store.globalState.user?.email ?? ""
            }
        }
        .withDefaultPadding(padding: .horizontal)
        .navigationbarHidden()
    }

    private func sendMessage() {
        guard isValidEmail(email) else {
            self.alert = ("Error", "Invalid Email")
            return
        }
        guard let message = message else {
            self.alert = ("Error", "Please enter your message")
            return
        }
        let loader = loader.getLoader()

        store.send(.main(action: .sendMessage(email: email, message: message, completion: { result in
            if case let .failure(error) = result {
                self.alert = ("Error", error.localizedDescription)
            } else {
                self.alert = ("Success", "Thanks for contacting us! We received your message and will get back to you shortly.")
            }
            self.message = nil
            loader(.success(()))
        })))
    }
}

extension ContactView: EmailValidator {}
