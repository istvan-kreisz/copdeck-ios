//
//  ContentView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 12/13/20.
//

import SwiftUI
import GoogleSignIn
// import FacebookLogin

struct LoginView: View {
    @EnvironmentObject var store: AuthenticationStore

    @State var email = ""
    @State var password = ""

    @State var isEditing = false
    @State var signUpTapped = false

    @State var resetPasswordPresented = false

    let color: Color = .customBlue

    init() {}

    var body: some View {
        NavigationView {
            ZStack {
                Color.customBackground.edgesIgnoringSafeArea(.all)
                NavigationLink("",
                               destination: SignUpView(),
                               isActive: $signUpTapped)
                VStack(alignment: .center, spacing: 8) {
                    Spacer()

                    Text("Welcome to CopDeck!")
                        .font(.bold(size: 22))
                        .foregroundColor(.customText1)
                        .leftAligned()
                    Text("Sign up  with socials or fill the form to continue.")
                        .font(.regular(size: 16))
                        .foregroundColor(.customText2)
                        .leftAligned()

                    HStack(spacing: 10) {
                        SignInButton(imageName: "apple",
                                     text: "Sign in with Apple",
                                     imageColor: .white,
                                     backgroundColor: .customBlack,
                                     action: { store.send(.signInWithApple) },
                                     initBlock: {})
                        SignInButton(imageName: "google",
                                     text: "Sign in with Google",
                                     imageColor: nil,
                                     backgroundColor: .white,
                                     action: { store.send(.signInWithGoogle) },
                                     initBlock: {})
                        SignInButton(imageName: "facebook",
                                     text: "Sign in with Facebook",
                                     imageColor: nil,
                                     backgroundColor: Color(r: 66, g: 103, b: 178),
                                     action: {
                                         #warning("yo")
                                     },
                                     initBlock: {
                                         #warning("yo")
//                                         store.send(action: .setFBLoginButtonDelegate(self.facebookButton.delegate))
                                     })
                        Spacer()
                    }
                    .padding(.top, 17)

                    Spacer()
                    TextFieldUnderlined(text: $email,
                                        isEditing: $isEditing,
                                        placeHolder: "Email",
                                        color: .customText1,
                                        dismissKeyboardOnReturn: false,
                                        icon: Image("profile"),
                                        keyboardType: .emailAddress,
                                        isSecureField: false,
                                        onFinishedEditing: {})
                    TextFieldUnderlined(text: $password,
                                        isEditing: $isEditing,
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
                                   size: .init(width: UIScreen.screenWidth - horizontalPadding * 2, height: 60),
                                   color: .customBlue,
                                   tapped: signIn)
                            .centeredHorizontally()
                        NextButton(text: "Create an account",
                                   size: .init(width: UIScreen.screenWidth - horizontalPadding * 2, height: 60),
                                   color: .customPurple,
                                   tapped: signUp)
                            .centeredHorizontally()
                    }
                    .padding(.top, 20)
                    Button.init(action: self.forgotPassword, label: {
                        Text("Forgot password?")
                            .underline()
                            .font(.regular(size: 16))
                            .foregroundColor(.customText1)
                    })
                    .leftAligned()
                    .padding(.top, 10)
                    .padding(.leading, 10)
                    Spacer()
                }
                .padding(.horizontal, horizontalPadding)
            }
            .navigationbarHidden()
            .sheet(isPresented: $resetPasswordPresented) {
                PasswordResetView(reset: resetPassword)
            }
        }
    }

    private func signIn() {
        store.send(.signIn(userName: email, password: password))
    }

    private func signUp() {
        signUpTapped = true
    }

    private func forgotPassword() {
        resetPasswordPresented = true
    }

    private func resetPassword(email: String) {
        store.send(.passwordReset(username: email))
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewDevice("iPhone 8")
            .environmentObject(AppStore(initialState: .mockAppState,
                                        reducer: appReducer,
                                        environment: World(isMockInstance: true)))
    }
}
