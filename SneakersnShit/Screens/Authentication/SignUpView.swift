//
//  SignUpView.swift
//  CopDeck
//
//  Created by István Kreisz on 1/29/21.
//

import SwiftUI
import GoogleSignIn
// import FacebookLogin

struct SignUpView: View {
    @EnvironmentObject var store: AppStore

    @State var email = ""
    @State var password1 = ""
    @State var password2 = ""

    @State var errorMessage: String?
    @State var resetPasswordPresented = false

    @Binding var showView: Bool

    let color: Color = .customBlue

    var body: some View {
        ZStack {
            Color.customBackground.edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 8) {
                NavigationBar(showView: $showView, title: nil, isBackButtonVisible: true, style: .light)

                Text("Sign up")
                    .font(.bold(size: 22))
                    .foregroundColor(.customText1)
                    .leftAligned()
                Text("Fill the form to create an account.")
                    .font(.regular(size: 16))
                    .foregroundColor(.customText2)
                    .leftAligned()
                Spacer()

                Group {
                    TextFieldUnderlined(text: $email,
                                        placeHolder: "Email",
                                        color: .customText1,
                                        dismissKeyboardOnReturn: false,
                                        icon: Image("profile"),
                                        keyboardType: .emailAddress,
                                        isSecureField: false,
                                        onFinishedEditing: {})
                    TextFieldUnderlined(text: $password1,
                                        placeHolder: "Password",
                                        color: .customText1,
                                        dismissKeyboardOnReturn: false,
                                        icon: Image("lock"),
                                        keyboardType: .default,
                                        isSecureField: true,
                                        onFinishedEditing: {})
                    TextFieldUnderlined(text: $password2,
                                        placeHolder: "Confirm password",
                                        color: .customText1,
                                        dismissKeyboardOnReturn: false,
                                        icon: Image("lock"),
                                        keyboardType: .default,
                                        isSecureField: true,
                                        onFinishedEditing: signUp)
                }

                NextButton(text: "Sign up",
                           size: .init(width: UIScreen.screenWidth - Styles.horizontalPadding * 2, height: 60),
                           color: .customBlue,
                           tapped: signUp)
                    .centeredHorizontally()
                    .padding(.top, 20)

                Button.init(action: { resetPasswordPresented = true }, label: {
                    Text("Forgot password?")
                        .underline()
                        .font(.regular(size: 16))
                        .foregroundColor(.customText1)
                })
                    .leftAligned()
                    .padding(.top, 10)
                    .padding(.leading, 10)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.semiBold(size: 16))
                        .foregroundColor(.customRed)
                        .centeredHorizontally()
                }
                Spacer()
            }
            .withDefaultPadding(padding: [.horizontal])
            .navigationbarHidden()
            .sheet(isPresented: $resetPasswordPresented) {
                PasswordResetView(reset: resetPassword)
            }
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
        store.send(.authentication(action: .signUp(userName: email, password: password1)))
    }

    private func resetPassword(email: String) {
        store.send(.authentication(action: .passwordReset(username: email)))
    }
}

extension SignUpView: EmailValidator {}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(showView: .constant(false))
            .previewDevice("iPhone 8")
            .environmentObject(AppStore.default)
    }
}
