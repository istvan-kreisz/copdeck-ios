//
//  PasswordResetView.swift
//  CopDeck
//
//  Created by István Kreisz on 1/29/21.
//

import SwiftUI

struct PasswordResetView: View {
    struct Feedback {
        let message: String
        let isError: Bool
    }

    @State var feedback: Feedback?
    @State var email = ""

    let reset: (String) -> Void

    var body: some View {
        ZStack {
            Color.customBackground.edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 8) {
                Spacer()
                Text("Forgot your password?")
                    .font(.bold(size: 22))
                    .foregroundColor(.customText1)
                    .leftAligned()
                Text("Enter your email below and we'll send you a reset link.")
                    .font(.regular(size: 16))
                    .foregroundColor(.customText2)
                    .leftAligned()
                Spacer()

                TextFieldUnderlined(text: $email,
                                    placeHolder: "Email",
                                    color: .customText1,
                                    dismissKeyboardOnReturn: true,
                                    icon: Image("profile"),
                                    keyboardType: .emailAddress,
                                    isSecureField: false,
                                    onFinishedEditing: {})

                NextButton(text: "Send reset link",
                           size: .init(width: UIScreen.screenWidth - Styles.horizontalPadding * 2, height: 60),
                           color: .customBlue,
                           tapped: resetPassword)
                    .centeredHorizontally()
                    .padding(.top, 20)

                if let feedback = self.feedback {
                    Text(feedback.message)
                        .font(.semiBold(size: 16))
                        .foregroundColor(feedback.isError ? .customRed : .customGreen)
                        .centeredHorizontally()
                }
                Spacer()
            }
            .withDefaultPadding(padding: .horizontal)
            .navigationbarHidden()
        }
    }

    private func resetPassword() {
        guard isValidEmail(email) else {
            feedback = Feedback(message: "Please enter a valid email address", isError: true)
            return
        }
        feedback = Feedback(message: "Reset link was sent to email", isError: false)
        reset(email)
    }
}

extension PasswordResetView: EmailValidator {}

struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetView { _ in }
            .previewDevice("iPhone 8")
            .environmentObject(AppStore.default)
    }
}
