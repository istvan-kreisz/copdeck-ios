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
    let authentication = Authentication(authenticator: DebugSettings.shared.useMockData ? MockAuthenticator() : DefaultAuthenticator())
    lazy var settings = AppSettings(settings: DebugSettings.shared.useMockData ? DefaultSettings() : DefaultSettings())
}
