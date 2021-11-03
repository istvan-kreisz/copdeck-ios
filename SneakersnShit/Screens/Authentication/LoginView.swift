//
//  ContentView.swift
//  CopDeck
//
//  Created by István Kreisz on 12/13/20.
//

import SwiftUI
import GoogleSignIn
// import FacebookLogin

struct LoginView: View {
    @State var email = DebugSettings.shared.loginCredentials?.username ?? ""
    @State var password = DebugSettings.shared.loginCredentials?.password ?? ""
    @State var signUpTapped = false
    @State var resetPasswordPresented = false

    let color: Color = .customBlue

    var body: some View {
        NavigationView {
            ZStack {
                Color.customBackground.edgesIgnoringSafeArea(.all)
                NavigationLink("",
                               destination: SignUpView(showView: $signUpTapped),
                               isActive: $signUpTapped)
                VStack(alignment: .center, spacing: 8) {
                    NavigationBar.placeHolder

                    VStack(alignment: .center, spacing: 8) {
                        Text("Welcome to CopDeck!")
                            .font(.bold(size: 22))
                            .foregroundColor(.customText1)
                            .leftAligned()
                        Text("Sign in to continue.")
                            .font(.regular(size: 16))
                            .foregroundColor(.customText2)
                            .leftAligned()
                        Text("Sign up  with socials or fill the form to continue.")
                            .font(.regular(size: 16))
                            .foregroundColor(.customText2)
                            .leftAligned()
                    }
                    SocialLoginView(referralCode: .constant(""))
                        .padding(.top, 17)
                    
                    Spacer()
                    TextFieldUnderlined(text: $email,
                                        placeHolder: "Email",
                                        color: .customText1,
                                        dismissKeyboardOnReturn: false,
                                        icon: Image("profile"),
                                        keyboardType: .emailAddress,
                                        isSecureField: false,
                                        onFinishedEditing: {})
                    TextFieldUnderlined(text: $password,
                                        placeHolder: "Password",
                                        color: .customText1,
                                        dismissKeyboardOnReturn: false,
                                        icon: Image("lock"),
                                        keyboardType: .default,
                                        isSecureField: true,
                                        onFinishedEditing: signIn)
                        .padding(.top, 25)
                        .padding(.bottom, 20)

                    VStack(spacing: 10) {
                        NextButton(text: "Sign In",
                                   size: .init(width: UIScreen.screenWidth - Styles.horizontalMargin * 2, height: 60),
                                   color: .customBlue,
                                   tapped: signIn)
                            .centeredHorizontally()
                        NextButton(text: "Create an account",
                                   size: .init(width: UIScreen.screenWidth - Styles.horizontalMargin * 2, height: 60),
                                   color: .customPurple,
                                   tapped: signUp)
                            .centeredHorizontally()
                    }
                    .padding(.top, 20)

                    Button(action: forgotPassword) {
                        Text("Forgot password?")
                            .underline()
                            .font(.regular(size: 16))
                            .foregroundColor(.customText1)
                    }
                    .leftAligned()
                    .padding(.top, 10)
                    .padding(.leading, 10)
                    
                    Spacer()
                }
                .padding(.horizontal, Styles.horizontalMargin)
            }
            .navigationbarHidden()
            .sheet(isPresented: $resetPasswordPresented) {
                PasswordResetView(reset: resetPassword)
            }
        }
    }

    private func signIn() {
        AppStore.default.send(.authentication(action: .signIn(userName: email, password: password)))
    }

    private func signUp() {
        signUpTapped = true
    }

    private func forgotPassword() {
        resetPasswordPresented = true
    }

    private func resetPassword(email: String) {
        AppStore.default.send(.authentication(action: .passwordReset(email: email)))
    }
}
