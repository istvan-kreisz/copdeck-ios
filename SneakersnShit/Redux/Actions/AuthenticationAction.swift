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
//    case signInWithFacebook
    case signOut
    case passwordReset(email: String)
    case deleteAccount
}

extension AuthenticationAction: StringRepresentable {}
