//
//  AuthenticatorService.swift
//  ToDo
//
//  Created by István Kreisz on 4/10/20.
//  Copyright © 2020 István Kreisz. All rights reserved.
//

//import FacebookLogin
import Foundation
import Combine

protocol Authenticator {
    func handle(_ authAction: AuthenticationAction) -> AnyPublisher<String, Error>
}

//extension Authenticator: LoginButtonDelegate {}
