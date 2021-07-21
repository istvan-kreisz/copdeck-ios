//
//  World.swift
//  CopDeck
//
//  Created by István Kreisz on 12/13/20.
//

import Foundation
import Combine

class World {
    let api: API
    let authenticator: Authenticator
    let databaseManager: DatabaseManager

    init(api: API, authenticator: Authenticator, databaseManager: DatabaseManager) {
        self.api = api
        self.authenticator = authenticator
        self.databaseManager = databaseManager
    }

    convenience init() {
        self.init(api: DefaultAPI(backendAPI: BackendAPI(), localScraper: LocalScraper()),
                authenticator: DefaultAuthenticator(),
                databaseManager: FirebaseService())
    }
}
