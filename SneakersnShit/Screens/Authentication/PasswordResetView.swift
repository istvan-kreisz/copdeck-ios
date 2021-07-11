//
//  PasswordResetView.swift
//  SneakersnShit
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
        VStack(alignment: .center, spacing: 20) {
            List {
                if let feedback = self.feedback {
                    HStack {
                        Spacer()
                        Text(feedback.message)
                            .font(.semiBold(size: 16))
                            .foregroundColor(feedback.isError ? .customRed : .customGreen)
                        Spacer()
                    }
                }
                InputField(text: $email,
                           isEditing: .constant(false),
                           placeHolder: "Email",
                           color: .customGreen,
                           dismissKeyboardOnReturn: true,
                           accessoryView: nil,
                           keyboardType: .emailAddress,
                           isSecureField: false,
                           onFinishedEditing: {})
                .textContentType(.emailAddress)
                HStack {
                    Spacer()
                    Button(action: resetPassword) {
                        Text("Send reset link")
                            .font(.semiBold(size: 25))
                            .foregroundColor(Color(.label))
                    }
                    .padding(.top, 15)
                    Spacer()
                }
            }
            .modifier(DefaultInsets())
            .padding(.top, 30)
        }
        .modifier(DefaultPadding())
        .navigationbarHidden()
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
    }
}
