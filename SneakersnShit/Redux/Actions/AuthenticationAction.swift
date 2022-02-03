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
    case signInWithApple(referralCode: String?)
    case signInWithGoogle(referralCode: String?)
    case signInWithFacebook(referralCode: String?)
    case signOut
    case passwordReset(email: String)
    case deleteAccount
}

extension AuthenticationAction: StringRepresentable {}
