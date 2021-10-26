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
    private var monthlyPackage: Purchases.Package?
    private var yearlyPackage: Purchases.Package?
    
    private let errorsSubject = PassthroughSubject<AppError, Never>()
    private let subscriptionActiveSubject = CurrentValueSubject<Bool?, Never>(nil)
    
    var subscriptionActivePublisher: AnyPublisher<Bool?, Never> {
        subscriptionActiveSubject.eraseToAnyPublisher()
    }
    var subscriptionActive: Bool? {
        subscriptionActiveSubject.value
    }
    var errorsPublisher: AnyPublisher<AppError, Never> {
        errorsSubject.eraseToAnyPublisher()
    }

    override init() {
        super.init()
        if DebugSettings.shared.isInDebugMode {
            Purchases.logLevel = .debug
        }
        Purchases.configure(withAPIKey: Self.apiKey)
//        Purchases.shared.delegate = self

        Purchases.shared.offerings { [weak self] offerings, error in
            error.map { self?.errorsSubject.send(AppError(error: $0)) }
            self?.monthlyPackage = offerings?.current?.monthly
            self?.yearlyPackage = offerings?.current?.annual
        }
        Purchases.shared.purchaserInfo { [weak self] purchaserInfo, error in
            error.map { self?.errorsSubject.send(AppError(error: $0)) }
            self?.purchaserInfo = purchaserInfo
        }
    }

    func setup(userId: String, userEmail: String?) {
        Purchases.shared.logIn(userId) { [weak self] purchaserInfo, created, error in
            error.map { self?.errorsSubject.send(AppError(error: $0)) }
            self?.purchaserInfo = purchaserInfo
            if created {
                Purchases.shared.setEmail(userEmail)
            }
        }
    }

    func reset() {
        Purchases.shared.logOut { [weak self] purchaseInfo, error in
            error.map { self?.errorsSubject.send(AppError(error: $0)) }
            if error != nil {
                self?.purchaserInfo = nil
            } else {
                self?.purchaserInfo = purchaseInfo
            }
        }
    }

    func restorePurchases() {
        Purchases.shared.restoreTransactions { [weak self] purchaserInfo, error in
            error.map { self?.errorsSubject.send(AppError(error: $0)) }
            self?.purchaserInfo = purchaserInfo
        }
    }
    
    func purchase(package: Purchases.Package) {
        Purchases.shared.purchasePackage(package) { [weak self] transaction, purchaserInfo, error, userCancelled in
            error.map { self?.errorsSubject.send(AppError(error: $0)) }
            self?.purchaserInfo = purchaserInfo
        }
    }
}

// extension DefaultPaymentService: PurchasesDelegate {
//    func purchases(_ purchases: Purchases, didReceiveUpdated purchaserInfo: Purchases.PurchaserInfo) {
//        self.purchaserInfo = purchaserInfo
//    }
// }
