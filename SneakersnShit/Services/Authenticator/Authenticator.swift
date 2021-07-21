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
    func handle(_ authAction: AuthenticationAction) -> AnyPublisher<String, Error>
    static var user: FirebaseAuth.User? { get }
}

//extension Authenticator: LoginButtonDelegate {}
