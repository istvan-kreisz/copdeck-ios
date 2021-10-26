//
//  PaymentService.swift
//  CopDeck
//
//  Created by István Kreisz on 10/25/21.
//

import Foundation
import Combine
import Purchases

protocol PaymentService {
    var subscriptionActive: Bool? { get }
    var subscriptionActivePublisher: AnyPublisher<Bool?, Never> { get }

    func setup(userId: String, userEmail: String?)
    func reset()
    func purchase(package: Purchases.Package)
    func restorePurchases()
}
