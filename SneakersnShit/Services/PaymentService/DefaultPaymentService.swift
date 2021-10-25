//
//  DefaultPaymentService.swift
//  CopDeck
//
//  Created by István Kreisz on 10/25/21.
//

import Foundation
import Purchases
import Combine

class DefaultPaymentService: NSObject, PaymentService {
    private static let entitlementsId = "pro"
    private static let apiKey = "vkJAtxOkCMEORPnQDmuEwtoUBuHDUMSu"
    
    private var purchaserInfo: Purchases.PurchaserInfo? {
        didSet {
            subscriptionActiveSubject.send(purchaserInfo?.entitlements[Self.entitlementsId]?.isActive == true)
        }
    }
    private var monthlyProduct: SKProduct?
    private var yearlyProduct: SKProduct?
    
    private let subscriptionActiveSubject = CurrentValueSubject<Bool?, Never>(nil)
    var subscriptionActivePublisher: AnyPublisher<Bool?, Never> {
        subscriptionActiveSubject.eraseToAnyPublisher()
    }
    var subscriptionActive: Bool? {
        subscriptionActiveSubject.value
    }

    override init() {
        super.init()
        if DebugSettings.shared.isInDebugMode {
            Purchases.logLevel = .debug
        }
        Purchases.configure(withAPIKey: Self.apiKey)
//        Purchases.shared.delegate = self

        Purchases.shared.offerings { [weak self] offerings, error in
            self?.monthlyProduct = offerings?.current?.monthly?.product
            self?.yearlyProduct = offerings?.current?.annual?.product
        }
        Purchases.shared.purchaserInfo { [weak self] purchaserInfo, error in
            self?.purchaserInfo = purchaserInfo
        }
    }

    func setup(userId: String, userEmail: String?) {
        Purchases.shared.logIn(userId) { [weak self] purchaserInfo, created, error in
            self?.purchaserInfo = purchaserInfo
            if created {
                Purchases.shared.setEmail(userEmail)
            }
        }
    }

    func reset() {
        Purchases.shared.logOut { purchaseInfo, error in
            if error != nil {
                self.purchaserInfo = nil
            } else {
                self.purchaserInfo = purchaseInfo
            }
        }
    }

    func restorePurchases() {
        Purchases.shared.restoreTransactions { [weak self] purchaserInfo, error in
            self?.purchaserInfo = purchaserInfo
        }
    }
}

// extension DefaultPaymentService: PurchasesDelegate {
//    func purchases(_ purchases: Purchases, didReceiveUpdated purchaserInfo: Purchases.PurchaserInfo) {
//        self.purchaserInfo = purchaserInfo
//    }
// }
