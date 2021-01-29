//
//  World.swift
//  InfluTrader
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

class World {
    private let isMock: Bool
    
    lazy var authentication = Authentication(authenticator: isMock ? MockAuthenticator() : DefaultAuthenticator())
    lazy var settings = AppSettings(settings: isMock ? DefaultSettings() : DefaultSettings())

    init(isMock: Bool) {
        self.isMock = isMock
    }
}
