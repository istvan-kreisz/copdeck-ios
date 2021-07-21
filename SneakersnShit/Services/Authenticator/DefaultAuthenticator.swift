//
//  DefaultAuthenticator.swift
//  CopDeck
//
//  Created by István Kreisz on 1/28/21.
//

import Foundation
import Combine
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookLogin
import GoogleSignIn
// import CryptoKit
// import AuthenticationServices

enum AuthError: Error {
    case userNotFound
}

class DefaultAuthenticator: NSObject, Authenticator {
    static private let auth = Auth.auth()
    static var user: FirebaseAuth.User? { auth.currentUser }

    private var userChangesSubject = PassthroughSubject<String, Error>()

//    fileprivate var currentNonce: String?
    private let loginButton = FBLoginButton()

    func handle(_ authAction: AuthenticationAction) -> AnyPublisher<String, Error> {
        userChangesSubject.send(completion: .finished)
        userChangesSubject = PassthroughSubject<String, Error>()
        switch authAction {
        case .restoreState:
            restoreState()
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
        }
        return userChangesSubject.eraseToAnyPublisher()
    }

    #warning("refactor")
    private func restoreState() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
                self?.handleGoogleSignInResult(user: user, error: error, isRestore: true)
            }
        } else if let fbAccessToken = AccessToken.current?.tokenString {
            handleFacebookSignInResult(accessToken: fbAccessToken)
        } else if let user = Self.auth.currentUser {
            sendResultWithDelay(user.uid)
        } else {
            signOut()
        }
    }

    private func signUp(email: String, password: String) {
        Self.auth.createUser(withEmail: email, password: password) { [weak self] authResult, error in
            self?.handleAuthResponse(result: authResult, error: error)
        }
    }

    private func signIn(email: String, password: String) {
        Self.auth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
            self?.handleAuthResponse(result: authResult, error: error)
        }
    }

    private func handleAuthResponse(result: AuthDataResult?, error: Error?) {
        if let error = error {
            userChangesSubject.send(completion: .failure(error))
            return
        }
        if let uid = result?.user.uid {
            userChangesSubject.send(uid)
        } else {
            userChangesSubject.send(completion: .failure(AuthError.userNotFound))
        }
    }

    private func signInWithFacebook() {
        loginButton.delegate = self
        loginButton.sendActions(for: .touchUpInside)
    }

    private func signInWithGoogle() {
        if let viewController = UIApplication.shared.windows.first?.rootViewController {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { [weak self] user, error in
                self?.handleGoogleSignInResult(user: user, error: error, isRestore: false)
            }
        }
    }

    private func handleGoogleSignInResult(user: GIDGoogleUser?, error: Error?, isRestore: Bool) {
        if let error = error {
            if isRestore {
                userChangesSubject.send("")
            } else {
                userChangesSubject.send(completion: .failure(error))
            }
            return
        }

        guard let authentication = user?.authentication, let idToken = authentication.idToken
        else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: authentication.accessToken)
        signIn(credential: credential)
    }

    private func signOut() {
        do {
            var signoutGoogle = false
            var signoutFacebook = false
            if GIDSignIn.sharedInstance.currentUser != nil {
                signoutGoogle = true
            }
            if AuthenticationToken.current != nil || AccessToken.current != nil {
                signoutFacebook = true
            }
            try Self.auth.signOut()
            if signoutGoogle {
                GIDSignIn.sharedInstance.signOut()
            }
            if signoutFacebook {
                LoginManager().logOut()
            }
            sendResultWithDelay("")
        } catch let signOutError as NSError {
            userChangesSubject.send(completion: .failure(signOutError))
        }
    }

    private func sendResultWithDelay(_ result: String) {
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] _ in
            self?.userChangesSubject.send(result)
        }
    }

    private func resetPassword(email: String) {
        Self.auth.sendPasswordReset(withEmail: email) { [weak self] error in
            if let error = error {
                self?.userChangesSubject.send(completion: .failure(error))
            } else {
                self?.userChangesSubject.send(completion: .finished)
            }
        }
    }

    fileprivate func signIn(credential: AuthCredential) {
        Self.auth.signIn(with: credential) { [weak self] authResult, error in
            self?.handleAuthResponse(result: authResult, error: error)
        }
    }
}

// MARK: - Sign in with Facebook

extension DefaultAuthenticator: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        userChangesSubject.send("")
    }

    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            userChangesSubject.send(completion: .failure(error))
            return
        }
        guard let token = AccessToken.current?.tokenString else {
            userChangesSubject.send(completion: .failure(AuthError.userNotFound))
            return
        }
        handleFacebookSignInResult(accessToken: token)
    }

    private func handleFacebookSignInResult(accessToken: String) {
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
        signIn(credential: credential)
    }
}

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
