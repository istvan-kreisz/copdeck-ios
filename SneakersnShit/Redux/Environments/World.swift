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
    let paymentService: PaymentService
    let pushNotificationService: PushNotificationService
    let searchService: SearchService
    let feedbackGenerator = UISelectionFeedbackGenerator()

    init(dataController: DataController, authenticator: Authenticator, paymentService: PaymentService, pushNotificationService: PushNotificationService, searchService: SearchService) {
        self.dataController = dataController
        self.authenticator = authenticator
        self.paymentService = paymentService
        self.pushNotificationService = pushNotificationService
        self.searchService = searchService
    }

    convenience init() {
        self.init(dataController: DefaultDataController(backendAPI: DefaultBackendAPI(),
                                                        databaseManager: DefaultDatabaseManager(),
                                                        imageService: DefaultImageService()),
                  authenticator: DefaultAuthenticator(),
                  paymentService: DefaultPaymentService(),
                  pushNotificationService: PushNotificationService(),
                  searchService: DefaultSearchService())
    }
}
