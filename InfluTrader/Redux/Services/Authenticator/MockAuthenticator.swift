//
//  MockAuthenticator.swift
//  ToDo
//
//  Created by István Kreisz on 4/10/20.
//  Copyright © 2020 István Kreisz. All rights reserved.
//

import Foundation
// import FacebookLogin
import Combine

class MockAuthenticator: NSObject, Authenticator {
    private let userChangesSubject = PassthroughSubject<String, Error>()

    func handle(_ authAction: AuthenticationAction) -> AnyPublisher<String, Error> {
        switch authAction {
        case .restoreState:
            userChangesSubject.send("hey")
        case .signUp:
            userChangesSubject.send("hey")
        case .signIn:
            userChangesSubject.send("hey")
        case .signInWithApple:
            userChangesSubject.send("hey")
        case .signInWithGoogle:
            userChangesSubject.send("hey")
        case .signInWithFacebook:
            userChangesSubject.send("hey")
        case .signOut:
            userChangesSubject.send("hey")
        case .passwordReset:
            break
        case .setUserId:
            break
        }
        return userChangesSubject.eraseToAnyPublisher()
    }

//    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {}

//    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {}
}
