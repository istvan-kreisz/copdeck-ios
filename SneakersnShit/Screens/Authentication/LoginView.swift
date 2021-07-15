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

    @State var signUpTapped: Int?

    let color: Color = .customBlue

    init() {}

    var body: some View {
        NavigationView {
            ZStack {
                Color.customBackground.edgesIgnoringSafeArea(.all)
                NavigationLink(destination: SignUpView(),
                               tag: 1,
                               selection: $signUpTapped) { EmptyView() }
                VStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 10) {
                        Spacer(minLength: 30)
                        Text("Welcome to CopDeck!")
                            .font(.bold(size: 22))
                            .foregroundColor(.customText1)
                        Text("Sign up  with socials or fill the form to continue.")
                            .font(.regular(size: 16))
                            .foregroundColor(.customText2)
                    }
                    InputField(text: $email,
                               isEditing: $isEditing,
                               placeHolder: "Email",
                               color: .white,
                               dismissKeyboardOnReturn: false,
                               accessoryView: nil,
                               keyboardType: .emailAddress,
                               isSecureField: false,
                               onFinishedEditing: {})
                    InputField(text: $password,
                               isEditing: $isEditing,
                               placeHolder: "Password",
                               color: .white,
                               dismissKeyboardOnReturn: false,
                               accessoryView: nil,
                               keyboardType: .default,
                               isSecureField: true,
                               onFinishedEditing: signIn)

//                        SignInButton(imageName: "apple",
//                                     text: "Sign in with Apple",
//                                     imageColor: Color(.label),
//                                     action: { self.store.send(action: .signInWithApple) },
//                                     initBlock: {})
                    SignInButton(imageName: "google",
                                 text: "Sign in with Google",
                                 imageColor: nil,
                                 action: { self.store.send(.signInWithGoogle) },
                                 initBlock: {})
//                        SignInButton(imageName: "facebook",
//                                     text: "Sign in with Facebook",
//                                     imageColor: nil,
//                                     action: { self.facebookButton.sendActions(for: .touchUpInside) },
//                                     initBlock: {
//                                        store.send(action: .setFBLoginButtonDelegate(self.facebookButton.delegate))
//                        })
                    RoundedButton(text: "Login",
                                  size: .init(width: 300, height: 60),
                                  color: .customBlue,
                                  tapped: signIn)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .centeredHorizontally()
                        .padding(.top, 20)
                    RoundedButton(text: "Create account",
                                  size: .init(width: 300, height: 60),
                                  color: .customPurple,
                                  tapped: signUp)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .centeredHorizontally()
                        .padding(.top, 20)
                    Spacer()
                }
                .modifier(DefaultPadding(padding: [.top, .leading, .trailing]))
            }
            .navigationbarHidden()
        }
    }

    private func signIn() {
        store.send(.signIn(userName: email, password: password))
    }

    private func signUp() {
        signUpTapped = 1
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppStore(initialState: .mockAppState,
                                        reducer: appReducer,
                                        environment: World(isMockInstance: true)))
    }
}
