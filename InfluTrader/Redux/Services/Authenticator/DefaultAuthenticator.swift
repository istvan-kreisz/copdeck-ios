//
//  DefaultAuthenticator.swift
//  InfluTrader
//
//  Created by István Kreisz on 1/28/21.
//

import Foundation
import Combine
import Firebase
import FirebaseAuth
// import FacebookLogin
import GoogleSignIn
// import CryptoKit
// import AuthenticationServices

class DefaultAuthenticator: NSObject, Authenticator {

    private var userChangesSubject = PassthroughSubject<String, Error>()

    // Unhashed nonce.
//    fileprivate var currentNonce: String?

    func handle(_ authAction: AuthenticationAction) -> AnyPublisher<String, Error> {
        userChangesSubject = PassthroughSubject<String, Error>()
        switch authAction {
        case .signUp(userName: let username, password: let password):
            signUp(email: username, password: password)
        case .signIn(userName: let username, password: let password):
            signIn(email: username, password: password)
        case .signInWithApple:
            signInWithApple()
        case .signInWithGoogle:
            signInWithGoogle()
        case .signInWithFacebook:
            signInWithFacebook()
        case .passwordReset(username: let email):
            resetPassword(email: email)
        case .signOut:
            signOut()
        case .setUserId:
            break
        }
        return userChangesSubject.eraseToAnyPublisher()
    }

    override init() {
        super.init()
        GIDSignIn.sharedInstance().delegate = self
    }

    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            error.map { self?.userChangesSubject.send(completion: .failure($0)) }
        }
    }

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            error.map { self?.userChangesSubject.send(completion: .failure($0)) }
        }
    }

    // MARK: - Firebase 🔥

    private func signInWithFacebook() {
//        // The following config can also be stored in the project's .plist
//        Settings.appID = kFacebookAppID
//        Settings.displayName = "AuthenticationExample"
//
//        // Create a Facebook `LoginManager` instance
//        let loginManager = LoginManager()
//        loginManager.logIn(permissions: ["email"], from: self) { result, error in
//            guard error == nil else { return self.displayError(error) }
//            guard let accessToken = AccessToken.current else { return }
//            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
//            self.signin(with: credential)
//        }
    }

    func signInWithGoogle() {
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()!.options.clientID

        // Start the sign in flow!
        if let viewController = UIApplication.shared.windows.first?.rootViewController {
            GIDSignIn.sharedInstance()?.presentingViewController = viewController
            GIDSignIn.sharedInstance()?.signIn()
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            userChangesSubject.send(completion: .failure(signOutError))
        }
    }

    func resetPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            error.map { self?.userChangesSubject.send(completion: .failure($0)) }
        }
    }

    fileprivate func signIn(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            error.map { self?.userChangesSubject.send(completion: .failure($0)) }
        }
    }
}

// MARK: - Sign in with Google

extension DefaultAuthenticator: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        guard error == nil else {
            error.map { userChangesSubject.send(completion: .failure($0)) }
            return
        }

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        self.signIn(credential: credential)
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        error.map { userChangesSubject.send(completion: .failure($0)) }
    }
}

// MARK: - Sign in with Facebook

// extension FirebaseAuthenticator: LoginButtonDelegate {
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
// }

// MARK: - Sign in with Apple

 extension DefaultAuthenticator {
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
    func signInWithApple() {
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
    }
//
//    private func sha256(_ input: String) -> String {
//        let inputData = Data(input.utf8)
//        let hashedData = SHA256.hash(data: inputData)
//        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
//        return hashString
//    }
 }

// MARK: - Implementing Sign in with Apple with Firebase

//
// extension FirebaseAuthenticator: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
//    // MARK: ASAuthorizationControllerDelegate
//
//    func authorizationController(controller: ASAuthorizationController,
//                                 didCompleteWithAuthorization authorization: ASAuthorization) {
//        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
//        else {
//            print("Unable to retrieve AppleIDCredential")
//            return
//        }
//
//        guard let nonce = currentNonce else {
//            fatalError("Invalid state: A login callback was received, but no login request was sent.")
//        }
//        guard let appleIDToken = appleIDCredential.identityToken else {
//            print("Unable to fetch identity token")
//            return
//        }
//        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
//            return
//        }
//
//        let credential = OAuthProvider.credential(withProviderID: "apple.com",
//                                                  idToken: idTokenString,
//                                                  rawNonce: nonce)
//
//        Auth.auth().signIn(with: credential) { result, error in
//            // Error. If error.code == .MissingOrInvalidNonce, make sure
//            // you're sending the SHA256-hashed nonce as a hex string with
//            // your request to Apple.
//            guard error == nil else { return self.displayError(error) }
//
//            // At this point, our user is signed in
//            // so we advance to the User View Controller
//            self.transitionToUserViewController()
//        }
//    }
//
//    func authorizationController(controller: ASAuthorizationController,
//                                 didCompleteWithError error: Error) {
//        // Ensure that you have:
//        //  - enabled `Sign in with Apple` on the Firebase console
//        //  - added the `Sign in with Apple` capability for this project
//        print("Sign in with Apple errored: \(error)")
//    }
//
//    // MARK: ASAuthorizationControllerPresentationContextProviding
//
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        UIApplication.shared.windows.first!
//    }
//
//    // MARK: Aditional `Sign in with Apple` Helpers
//
//    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
//    private func randomNonceString(length: Int = 32) -> String {
//        precondition(length > 0)
//        let charset: [Character] =
//            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
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
//
//        return result
//    }
//
//    private func sha256(_ input: String) -> String {
//        let inputData = Data(input.utf8)
//        let hashedData = SHA256.hash(data: inputData)
//        let hashString = hashedData.compactMap {
//            String(format: "%02x", $0)
//        }.joined()
//
//        return hashString
//    }
// }
