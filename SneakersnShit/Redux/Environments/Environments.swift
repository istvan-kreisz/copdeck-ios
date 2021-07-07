//
//  World.swift
//  SneakersnShit
//
//  Created by István Kreisz on 12/13/20.
//

import Foundation
import Combine

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
    let api: API

    init(api: API) {
        self.api = api
    }
}

class World {

    private let isMockInstance: Bool
    
    lazy var authentication = Authentication(authenticator: isMockInstance ? MockAuthenticator() : DefaultAuthenticator())
    lazy var settings = AppSettings(settings: DefaultSettings())
    lazy var main = Main(api: DefaultAPI(backendAPI: BackendAPI(), localScraper: LocalScraper()))

    init(isMockInstance: Bool) {
        self.isMockInstance = isMockInstance
    }
    
}
