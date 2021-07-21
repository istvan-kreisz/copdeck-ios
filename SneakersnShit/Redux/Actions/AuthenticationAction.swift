//
//  AuthenticationAction.swift
//  CopDeck
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation

enum AuthenticationAction {
    case restoreState
    case signUp(userName: String, password: String)
    case signIn(userName: String, password: String)
    case signInWithApple
    case signInWithGoogle
    case signInWithFacebook
    case signOut
    case passwordReset(username: String)
//    case setFBLoginButtonDelegate(delegate: LoginButtonDelegate)
}

extension AuthenticationAction: IdAble {
    var id: String {
        switch self {
        case .restoreState:
            return "restoreState"
        case .signUp:
            return "signUp"
        case .signIn:
            return "signIn"
        case .signInWithApple:
            return "signInWithApple"
        case .signInWithGoogle:
            return "signInWithGoogle"
        case .signInWithFacebook:
            return "signInWithFacebook"
        case .signOut:
            return "signOut"
        case .passwordReset:
            return "passwordReset"
        }
    }
}
