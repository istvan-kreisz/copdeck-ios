//
//  AuthenticatorService.swift
//  CopDeck
//
//  Created by István Kreisz on 4/10/20.
//  Copyright © 2020 István Kreisz. All rights reserved.
//

//import FacebookLogin
import Foundation
import Combine
import FirebaseAuth

protocol Authenticator {
    static var user: FirebaseAuth.User? { get }
    
    func restoreState() -> AnyPublisher<String, Error>
    func signUp(email: String, password: String) -> AnyPublisher<String, Error>
    func signIn(email: String, password: String) -> AnyPublisher<String, Error>
    func signInWithApple() -> AnyPublisher<String, Error>
    func signInWithGoogle() -> AnyPublisher<String, Error>
//    func signInWithFacebook() -> AnyPublisher<(userId: String, url: String?), Error>
    func resetPassword(email: String) -> AnyPublisher<String, Error>
    func signOut() ->  AnyPublisher<String, Error>
}
