//
//  ContentView.swift
//  InfluTrader
//
//  Created by István Kreisz on 12/13/20.
//

import SwiftUI
import GoogleSignIn
//import FacebookLogin

struct LoginView: View {
    
    @EnvironmentObject var store: Store<UserState, AuthenticationAction, Authentication>

    @State var email = ""
    @State var password = ""
    
    @State var isEditing = false
    
    @State var signUpTapped: Int?
    
    let color: Color = .customBlue
        
    init() {}
    
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(destination: SignUpView(),
                               tag: 1,
                               selection: $signUpTapped) { EmptyView() }
                VStack(alignment: .center) {
                    Text("Welcome to _")
                        .font(.bold(size: 34))
                        .foregroundColor(Color(UIColor.label))
                    List {
                        InputField(text: $email,
                                   isEditing: $isEditing,
                                   placeHolder: "Email",
                                   color: .customLightGray2,
                                   dismissKeyboardOnReturn: false,
                                   accessoryView: nil,
                                   keyboardType: .emailAddress,
                                   isSecureField: false,
                                   onFinishedEditing: {})
                        InputField(text: $password,
                                   isEditing: $isEditing,
                                   placeHolder: "Password",
                                   color: .customLightGray2,
                                   dismissKeyboardOnReturn: false,
                                   accessoryView: nil,
                                   keyboardType: .default,
                                   isSecureField: true,
                                   onFinishedEditing: signIn)
                        
                        DefaultButton(text: "Sign in",
                                      color: .customGreen,
                                      tapped: signIn)
                            .centeredHorizontally()
                            .padding(.top, 20)
                        
                        DefaultButton(text: "Create account",
                                      color: .customYellow,
                                      tapped: signUp)
                            .centeredHorizontally()
                                                
                        Text("OR")
                            .font(.bold(size: 28))
                            .foregroundColor(.customLightGray2)//.customGreen)
                            .centeredHorizontally()
                            .padding(.vertical, 2)
                        
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
                    }
                    .padding(.vertical, 20)
                    .modifier(DefaultInsets())
                }
                .modifier(DefaultPadding(padding: [.top, .leading, .trailing]))
            }
            .navigationBarTitle("")
//            .navigationBarHidden(true)
        }
    }
    
    private func signIn() {
        store.send(.signIn(userName: email, password: password))
    }
    
    private func signUp() {
        signUpTapped = 1
    }
}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//            .environmentObject(Store)
//    }
//}

struct DefaultButton: View {
    
    let text: String
    let color: Color
    let tapped: () -> Void
    
    init(text: String, color: Color = .customBlue, tapped: @escaping () -> Void) {
        self.text = text
        self.color = color
        self.tapped = tapped
    }
    
    var body: some View {
        Button(action: tapped) {
            Text(text)
                .font(.semiBold(size: 27))
                .foregroundColor(color)
        }
        .frame(width: 230, height: 45)
//        .overlay(
//            RoundedRectangle(cornerRadius: 25)
//                .stroke(color, lineWidth: 2)
//        )
//            .modifier(DefaultShadow())
    }
}
