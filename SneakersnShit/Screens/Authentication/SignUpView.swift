//
//  SignUpView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/29/21.
//

import SwiftUI
import GoogleSignIn
// import FacebookLogin

struct SignUpView: View {
    @EnvironmentObject var store: AuthenticationStore

    @State var email = ""
    @State var password1 = ""
    @State var password2 = ""

    @State var errorMessage: String?

    @State var resetPasswordPresented = false

//    @State var isEditing = false

    let color: Color = .customBlue

    var body: some View {
        ZStack {
            Color.customBackground.edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 8) {
                Spacer()
                Text("Welcome to CopDeck!")
                    .font(.bold(size: 22))
                    .foregroundColor(.customText1)
                    .leftAligned()
                Text("Fill the form to create an account.")
                    .font(.regular(size: 16))
                    .foregroundColor(.customText2)
                    .leftAligned()
                Spacer()

                TextFieldUnderlined(text: $email,
                                    isEditing: .constant(false),
                                    placeHolder: "Email",
                                    color: .customText1,
                                    dismissKeyboardOnReturn: false,
                                    icon: Image("profile"),
                                    keyboardType: .emailAddress,
                                    isSecureField: false,
                                    onFinishedEditing: {})
                TextFieldUnderlined(text: $password1,
                                    isEditing: .constant(false),
                                    placeHolder: "Password",
                                    color: .customText1,
                                    dismissKeyboardOnReturn: false,
                                    icon: Image("lock"),
                                    keyboardType: .default,
                                    isSecureField: true,
                                    onFinishedEditing: {})

                TextFieldUnderlined(text: $password2,
                                    isEditing: .constant(false),
                                    placeHolder: "Confirm password",
                                    color: .customText1,
                                    dismissKeyboardOnReturn: false,
                                    icon: Image("lock"),
                                    keyboardType: .default,
                                    isSecureField: true,
                                    onFinishedEditing: signUp)


                NextButton(text: "Sign up",
                           size: .init(width: UIScreen.screenWidth - horizontalPadding * 2, height: 60),
                           color: .customBlue,
                           tapped: signUp)
                    .centeredHorizontally()
                    .padding(.top, 20)
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.semiBold(size: 16))
                        .foregroundColor(.customRed)
                        .centeredHorizontally()
                }
                Spacer()
            }
            .modifier(DefaultPadding())
            .navigationbarHidden()
            .sheet(isPresented: $resetPasswordPresented) {
                PasswordResetView(reset: self.resetPassword)
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

// struct LoginView: View {
//    @EnvironmentObject var store: AuthenticationStore
//
//    @State var email = ""
//    @State var password = ""
//
//    @State var isEditing = false
//    @State var signUpTapped = false
//
//    let color: Color = .customBlue
//
//    static let horizontalPadding: CGFloat = 28
//
//    init() {}
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                Color.customBackground.edgesIgnoringSafeArea(.all)
//                NavigationLink("",
//                               destination: SignUpView(),
//                               isActive: $signUpTapped)
//                VStack(alignment: .center, spacing: 8) {
//                    Spacer()
//
//                    Text("Welcome to CopDeck!")
//                        .font(.bold(size: 22))
//                        .foregroundColor(.customText1)
//                        .leftAligned()
//                    Text("Sign up  with socials or fill the form to continue.")
//                        .font(.regular(size: 16))
//                        .foregroundColor(.customText2)
//                        .leftAligned()
//
//                    HStack(spacing: 10) {
//                        SignInButton(imageName: "apple",
//                                     text: "Sign in with Apple",
//                                     imageColor: .white,
//                                     backgroundColor: .customBlack,
//                                     action: { store.send(.signInWithApple) },
//                                     initBlock: {})
//                        SignInButton(imageName: "google",
//                                     text: "Sign in with Google",
//                                     imageColor: nil,
//                                     backgroundColor: .white,
//                                     action: { store.send(.signInWithGoogle) },
//                                     initBlock: {})
//                        SignInButton(imageName: "facebook",
//                                     text: "Sign in with Facebook",
//                                     imageColor: nil,
//                                     backgroundColor: Color(r: 66, g: 103, b: 178),
//                                     action: {
//                                         #warning("yo")
//                                     },
//                                     initBlock: {
//                                         #warning("yo")
////                                         store.send(action: .setFBLoginButtonDelegate(self.facebookButton.delegate))
//                                     })
//                        Spacer()
//                    }
//                    .padding(.top, 17)
//
//                    Spacer()
//                    TextFieldUnderlined(text: $email,
//                                        isEditing: $isEditing,
//                                        placeHolder: "Email",
//                                        color: .customText1,
//                                        dismissKeyboardOnReturn: false,
//                                        icon: Image("profile"),
//                                        keyboardType: .emailAddress,
//                                        isSecureField: false,
//                                        onFinishedEditing: {})
//                    TextFieldUnderlined(text: $password,
//                                        isEditing: $isEditing,
//                                        placeHolder: "Password",
//                                        color: .customText1,
//                                        dismissKeyboardOnReturn: false,
//                                        icon: Image("lock"),
//                                        keyboardType: .default,
//                                        isSecureField: true,
//                                        onFinishedEditing: signIn)
//                        .padding(.top, 25)
//                        .padding(.bottom, 20)
//
//                    Group {
//                        NextButton(text: "Sign In",
//                                   size: .init(width: UIScreen.screenWidth - Self.horizontalPadding * 2, height: 60),
//                                   color: .customBlue,
//                                   tapped: signIn)
//                            .frame(height: 60)
//                            .frame(maxWidth: UIScreen.screenWidth - 56)
//                            .centeredHorizontally()
//                            .padding(.top, 20)
//                        NextButton(text: "Create an account",
//                                   size: .init(width: UIScreen.screenWidth - Self.horizontalPadding * 2, height: 60),
//                                   color: .customPurple,
//                                   tapped: signUp)
//                            .frame(height: 60)
//                            .frame(maxWidth: .infinity)
//                            .centeredHorizontally()
//                            .padding(.top, 20)
//                    }
//                    Button.init(action: self.forgotPassword, label: {
//                        Text("Forgot password?")
//                            .underline()
//                            .font(.regular(size: 16))
//                            .foregroundColor(.customText1)
//                    })
//                    .leftAligned()
//                    .padding(.top, 10)
//                    .padding(.leading, 10)
//                    Spacer()
//                }
//                .padding(.horizontal, Self.horizontalPadding)
//            }
//            .navigationbarHidden()
//        }
//    }
//
//    private func signIn() {
//        store.send(.signIn(userName: email, password: password))
//    }
//
//    private func signUp() {
//        signUpTapped = true
//    }
//
//    private func forgotPassword() {
//        signUpTapped = true
//    }
// }

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .previewDevice("iPhone 8")
            .environmentObject(AppStore(initialState: .mockAppState,
                                        reducer: appReducer,
                                        environment: World(isMockInstance: true)))
    }
}
