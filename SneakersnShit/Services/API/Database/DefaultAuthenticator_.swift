////
////  FirebaseAuthenticator.swift
////  ToDo
////
////  Created by István Kreisz on 4/10/20.
////  Copyright © 2020 István Kreisz. All rights reserved.
////
//
//import Foundation
//import Combine
//import Firebase
//import FirebaseAuth
//import FacebookLogin
//import GoogleSignIn
//import CryptoKit
//import AuthenticationServices
//
//
//class FirebaseAuthenticator: NSObject, Authenticator {
//
//    var userChanges: AnyPublisher<String?, Never> {
//        userChangesSubject.eraseToAnyPublisher()
//    }
//    var errorMessage: AnyPublisher<String?, Never> {
//        errorMessageSubject.eraseToAnyPublisher()
//    }
//
//    private let userChangesSubject = PassthroughSubject<String?, Never>()
//    private let errorMessageSubject = PassthroughSubject<String?, Never>()
//    private var userChangeListener: AuthStateDidChangeListenerHandle?
//
//    // Unhashed nonce.
//    fileprivate var currentNonce: String?
//
//    func handle(_ authAction: AuthenticationAction) {
//        switch authAction {
//        case .signUp(userName: let username, password: let password):
//            signUp(email: username, password: password)
//        case .signIn(userName: let username, password: let password):
//            signIn(email: username, password: password)
//        case .signInWithApple:
//            startSignInWithAppleFlow()
//        case .signInWithGoogle:
//            break
//        case .signInWithFacebook:
//            break
//        case .passwordReset(username: let email):
//            resetPassword(email: email)
//        case .signOut:
//            signOut()
//        }
//    }
//
//    override init() {
//        super.init()
//        userChangeListener = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
//            self?.userChangesSubject.send(user?.uid)
//        }
//        GIDSignIn.sharedInstance().delegate = self
//    }
//
//    func signUp(email: String, password: String) {
//        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
//            self?.errorMessageSubject.send(error?.localizedDescription)
//        }
//    }
//
//    func signIn(email: String, password: String) {
//        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
//            self?.errorMessageSubject.send(error?.localizedDescription)
//        }
//    }
//
//    func signInWithGoogle() {
//        GIDSignIn.sharedInstance().signIn()
//    }
//
//    func signOut() {
//        do {
//            try Auth.auth().signOut()
//        } catch let signOutError as NSError {
//            errorMessageSubject.send(signOutError.localizedDescription)
//        }
//    }
//
//    func resetPassword(email: String) {
//        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
//            self?.errorMessageSubject.send(error?.localizedDescription)
//        }
//    }
//
//    fileprivate func signIn(credential: AuthCredential) {
//        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
//            self?.errorMessageSubject.send(error?.localizedDescription)
//        }
//    }
//}
//
//// MARK: - Sign in with Google
//
//extension FirebaseAuthenticator: GIDSignInDelegate {
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
//        guard error == nil else {
//            errorMessageSubject.send(error?.localizedDescription)
//            return
//        }
//
//        guard let authentication = user.authentication else { return }
//        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
//        self.signIn(credential: credential)
//    }
//
//    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
//        errorMessageSubject.send(error.localizedDescription)
//    }
//}
//
//// MARK: - Sign in with Facebook
//
//extension FirebaseAuthenticator: LoginButtonDelegate {
//
//    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
//        print("I'm logged out yo")
//    }
//
//    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
//        if let error = error {
//            errorMessageSubject.send(error.localizedDescription)
//            return
//        }
//        guard let token = AccessToken.current?.tokenString else { return }
//        let credential = FacebookAuthProvider.credential(withAccessToken: token)
//        self.signIn(credential: credential)
//    }
//}
//
//// MARK: - Sign in with Apple
//
//extension FirebaseAuthenticator {
//
//    private func randomNonceString(length: Int = 32) -> String {
//        precondition(length > 0)
//        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
//        var result = ""
//        var remainingLength = length
//
//        while remainingLength > 0 {
//            let randoms: [UInt8] = (0 ..< 16).map { _ in
//                var random: UInt8 = 0
//                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
//                if errorCode != errSecSuccess {
//                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
//                }
//                return random
//            }
//
//            randoms.forEach { random in
//                if remainingLength == 0 {
//                    return
//                }
//
//                if random < charset.count {
//                    result.append(charset[Int(random)])
//                    remainingLength -= 1
//                }
//            }
//        }
//        return result
//    }
//
//    func startSignInWithAppleFlow() {
//        let nonce = randomNonceString()
//        currentNonce = nonce
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        request.requestedScopes = [.fullName, .email]
//        request.nonce = sha256(nonce)
//
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
//        authorizationController.performRequests()
//    }
//
//    private func sha256(_ input: String) -> String {
//        let inputData = Data(input.utf8)
//        let hashedData = SHA256.hash(data: inputData)
//        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
//        return hashString
//    }
//}
//
//extension FirebaseAuthenticator: ASAuthorizationControllerPresentationContextProviding {
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        UIApplication.shared.windows.first!
//    }
//}
//
//
//extension FirebaseAuthenticator: ASAuthorizationControllerDelegate {
//
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            guard let nonce = currentNonce else {
//                fatalError("Invalid state: A login callback was received, but no login request was sent.")
//            }
//            guard let appleIDToken = appleIDCredential.identityToken else {
//                print("Unable to fetch identity token")
//                return
//            }
//            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
//                return
//            }
//            let credential = OAuthProvider.credential(withProviderID: "apple.com",
//                                                      idToken: idTokenString,
//                                                      rawNonce: nonce)
//            signIn(credential: credential)
//        }
//    }
//
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        if !error.localizedDescription.contains("1001") {
//            errorMessageSubject.send(error.localizedDescription)
//        }
//    }
//}
