//
//  SignUpView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/29/21.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var store: Store<UserIdState, AuthenticationAction, Authentication>

    @State var email = ""
    @State var password1 = ""
    @State var password2 = ""

    @State var errorMessage: String?

    @State var resetPasswordPresented = false

    let color: Color = .customBlue

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            List {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.semiBold(size: 16))
                        .foregroundColor(.customRed)
                        .centeredHorizontally()
                }
                InputField(text: $email,
                           isEditing: .constant(false),
                           placeHolder: "Email",
                           color: .customLightGray2,
                           dismissKeyboardOnReturn: false,
                           accessoryView: nil,
                           keyboardType: .emailAddress,
                           isSecureField: false,
                           onFinishedEditing: {})
                    .textContentType(.emailAddress)
                InputField(text: $password1,
                           isEditing: .constant(false),
                           placeHolder: "Password",
                           color: .customLightGray2,
                           dismissKeyboardOnReturn: false,
                           accessoryView: nil,
                           keyboardType: .default,
                           isSecureField: true,
                           onFinishedEditing: {})
                    .textContentType(.newPassword)
                InputField(text: $password2,
                           isEditing: .constant(false),
                           placeHolder: "Confirm password",
                           color: .customLightGray2,
                           dismissKeyboardOnReturn: false,
                           accessoryView: nil,
                           keyboardType: .default,
                           isSecureField: true,
                           onFinishedEditing: signUp)
                    .textContentType(.newPassword)

                DefaultButton(text: "Sign up",
                              color: .customGreen,
                              tapped: signUp)
                    .centeredHorizontally()
                    .padding(.top, 20)

                DefaultButton(text: "Reset password",
                              color: Color(.customRed),
                              tapped: presentPasswordResetView)
                    .centeredHorizontally()
            }
            .modifier(DefaultInsets())
            .padding(.vertical, 20)
        }
        .modifier(DefaultPadding())
        .navigationBarTitle("")
//        .navigationBarHidden(true)
        .sheet(isPresented: $resetPasswordPresented) {
            PasswordResetView(reset: self.resetPassword)
        }
    }

    private func signUp() {
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return
        }
        guard !password1.isEmpty else {
            errorMessage = "Invalid password"
            return
        }
        guard password1 == password2 else {
            errorMessage = "Passwords don't match"
            return
        }
        errorMessage = nil
        store.send(.signUp(userName: email, password: password1))
    }

    private func presentPasswordResetView() {
        resetPasswordPresented = true
    }

    private func resetPassword(email: String) {
        store.send(.passwordReset(username: email))
    }
}

extension SignUpView: EmailValidator {}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
