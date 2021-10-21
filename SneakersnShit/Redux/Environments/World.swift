//
//  World.swift
//  CopDeck
//
//  Created by István Kreisz on 12/13/20.
//

import Foundation
import Combine
import UIKit

class World {
    let dataController: DataController
    let authenticator: Authenticator
    let feedbackGenerator = UISelectionFeedbackGenerator()

    init(dataController: DataController, authenticator: Authenticator) {
        self.dataController = dataController
        self.authenticator = authenticator
    }

    convenience init() {
        self.init(dataController: DefaultDataController(backendAPI: DefaultBackendAPI(),
                                                        localScraper: LocalScraper(),
                                                        databaseManager: FirebaseService(),
                                                        imageService: DefaultImageService()),
                  authenticator: DefaultAuthenticator())
    }
}
