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
import CryptoKit
import AuthenticationServices

enum AuthError: LocalizedError {
    case userNotFound

    var errorDescription: String? {
        "User not found"
    }
}

class DefaultAuthenticator: NSObject, Authenticator {
    private static let auth = Auth.auth()
    static var user: FirebaseAuth.User? { auth.currentUser }

    private var userChangesSubject = PassthroughSubject<String, Error>()

    fileprivate var currentNonce: String?
    private let loginButton = FBLoginButton()

    private func withPublisher(block: () -> Void) -> AnyPublisher<String, Error> {
        userChangesSubject.send(completion: .finished)
        userChangesSubject = PassthroughSubject<String, Error>()
        block()
        return userChangesSubject.prefix(1).eraseToAnyPublisher()
    }

    func restoreState() -> AnyPublisher<String, Error> {
        return withPublisher { [weak self] in
            guard let self = self else { return }
            if let user = Self.auth.currentUser {
                self.sendResultWithDelay(user.uid)
            } else if GIDSignIn.sharedInstance.hasPreviousSignIn() {
                GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
                    self?.handleGoogleSignInResult(user: user, error: error, isRestore: true)
                }
            } else if let fbAccessToken = AccessToken.current?.tokenString {
                self.handleFacebookSignInResult(accessToken: fbAccessToken)
            } else {
                self.signOutUser()
            }
        }
    }

    func signUp(email: String, password: String) -> AnyPublisher<String, Error> {
        return withPublisher { [weak self] in
            Self.auth.createUser(withEmail: email, password: password) { [weak self] authResult, error in
                self?.handleAuthResponse(result: authResult, error: error)
            }
        }
    }

    func signIn(email: String, password: String) -> AnyPublisher<String, Error> {
        return withPublisher { [weak self] in
            Self.auth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
                self?.handleAuthResponse(result: authResult, error: error)
            }
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

    func signInWithFacebook() -> AnyPublisher<(userId: String, url: String?), Error> {
        return withPublisher { [weak self] in
            self?.loginButton.delegate = self
            self?.loginButton.permissions = ["email", "user_link"]
            self?.loginButton.sendActions(for: .touchUpInside)
        }
        .map { (userId: $0, url: Profile.current?.linkURL?.absoluteString) }
        .eraseToAnyPublisher()
    }

    func signInWithGoogle() -> AnyPublisher<String, Error> {
        return withPublisher { [weak self] in
            if let viewController = UIApplication.shared.windows.first?.rootViewController {
                guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                let config = GIDConfiguration(clientID: clientID)
                GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { [weak self] user, error in
                    self?.handleGoogleSignInResult(user: user, error: error, isRestore: false)
                }
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
        }

        guard let authentication = user?.authentication, let idToken = authentication.idToken
        else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
        signIn(credential: credential)
    }

    func signOut() -> AnyPublisher<String, Error> {
        return withPublisher { [weak self] in
            self?.signOutUser()
        }
    }

    private func signOutUser() {
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

    func resetPassword(email: String) -> AnyPublisher<String, Error> {
        return withPublisher { [weak self] in
            Self.auth.sendPasswordReset(withEmail: email) { [weak self] error in
                if let error = error {
                    self?.userChangesSubject.send(completion: .failure(error))
                } else {
                    self?.userChangesSubject.send(completion: .finished)
                }
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
    func signInWithApple() -> AnyPublisher<String, Error> {
        return withPublisher { [weak self] in
            let nonce = randomNonceString()
            self?.currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
}

extension DefaultAuthenticator: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            signIn(credential: credential)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        userChangesSubject.send(completion: .failure(error))
        log("Sign in with Apple errored: \(error)", logType: .error)
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.windows.first!
    }
}
