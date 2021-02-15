//
//  World.swift
//  SneakersnShit
//
//  Created by István Kreisz on 12/13/20.
//

import Foundation
import Combine

protocol Settings {}

class DefaultSettings: Settings {}

class AppSettings {
    let settings: Settings

    init(settings: Settings) {
        self.settings = settings
    }
}

class Authentication {
    let authenticator: Authenticator

    init(authenticator: Authenticator) {
        self.authenticator = authenticator
    }
}

class Main {
    let functions: FunctionsManager

    init(functions: FunctionsManager) {
        self.functions = functions
    }
}

class World {

    private let isMockInstance: Bool
    
    lazy var authentication = Authentication(authenticator: isMockInstance ? MockAuthenticator() : DefaultAuthenticator())
    lazy var settings = AppSettings(settings: DefaultSettings())
    lazy var main = Main(functions: DefaultFunctionsManager())

    init(isMockInstance: Bool) {
        self.isMockInstance = isMockInstance
    }
    
}
