//
//  DefaultPaymentService.swift
//  CopDeck
//
//  Created by István Kreisz on 10/25/21.
//

import Foundation
import Purchases
import Combine

struct SubscriptionPackages: Equatable {
    var monthlyPackage: Purchases.Package?
    var yearlyPackage: Purchases.Package?
}

class DefaultPaymentService: NSObject, PaymentService {
    static let entitlementsId = "pro"
    static let apiKey = "vkJAtxOkCMEORPnQDmuEwtoUBuHDUMSu"

    private let errorsSubject = PassthroughSubject<AppError, Never>()
    private let packagesSubject = CurrentValueSubject<SubscriptionPackages?, Never>(nil)
    private let purchaserInfoSubject = PassthroughSubject<Purchases.PurchaserInfo?, Never>()

    var errorsPublisher: AnyPublisher<AppError, Never> {
        errorsSubject.eraseToAnyPublisher()
    }
    var packagesPublisher: AnyPublisher<SubscriptionPackages?, Never> {
        packagesSubject.removeDuplicates().eraseToAnyPublisher()
    }
    var purchaserInfoPublisher: AnyPublisher<Purchases.PurchaserInfo?, Never> {
        purchaserInfoSubject.removeDuplicates().eraseToAnyPublisher()
    }

    override init() {
        super.init()
        if DebugSettings.shared.isInDebugMode {
            Purchases.logLevel = .debug
        }
        Purchases.configure(withAPIKey: Self.apiKey)
//        Purchases.shared.delegate = self

        getPackages(completion: nil)
        Purchases.shared.purchaserInfo { [weak self] purchaserInfo, error in
            error.map { self?.errorsSubject.send(AppError(error: $0)) }
            if purchaserInfo != nil {
                self?.purchaserInfoSubject.send(purchaserInfo)
            }
        }
    }

    func setup(userId: String, userEmail: String?) {
        if packagesSubject.value?.monthlyPackage == nil || packagesSubject.value?.yearlyPackage == nil {
            getPackages { [weak self] in
                self?.login(userId: userId, userEmail: userEmail)
            }
        } else {
            login(userId: userId, userEmail: userEmail)
        }
    }

    func reset() {
        Purchases.shared.logOut { [weak self] purchaseInfo, error in
            error.map { self?.errorsSubject.send(AppError(error: $0)) }
            if error != nil {
                self?.purchaserInfoSubject.send(nil)
            } else {
                self?.purchaserInfoSubject.send(purchaseInfo)
            }
        }
    }

    func restorePurchases() {
        Purchases.shared.restoreTransactions { [weak self] purchaserInfo, error in
            error.map { self?.errorsSubject.send(AppError(error: $0)) }
            self?.purchaserInfoSubject.send(purchaserInfo)
        }
    }

    func purchase(package: Purchases.Package) {
        Purchases.shared.purchasePackage(package) { [weak self] transaction, purchaserInfo, error, userCancelled in
            error.map { self?.errorsSubject.send(AppError(error: $0)) }
            self?.purchaserInfoSubject.send(purchaserInfo)
        }
    }
    
    private func getPackages(completion: (() -> Void)?) {
        Purchases.shared.offerings { [weak self] offerings, error in
            error.map { self?.errorsSubject.send(AppError(error: $0)) }
            self?.packagesSubject.send(.init(monthlyPackage: offerings?.current?.monthly, yearlyPackage: offerings?.current?.annual))
            completion?()
        }
    }
    
    private func login(userId: String, userEmail: String?) {
        Purchases.shared.logIn(userId) { [weak self] purchaserInfo, created, error in
            error.map { self?.errorsSubject.send(AppError(error: $0)) }
            self?.purchaserInfoSubject.send(purchaserInfo)
            if created {
                Purchases.shared.setEmail(userEmail)
            }
        }
    }
}

// extension DefaultPaymentService: PurchasesDelegate {
//    func purchases(_ purchases: Purchases, didReceiveUpdated purchaserInfo: Purchases.PurchaserInfo) {
//        self.purchaserInfo = purchaserInfo
//    }
// }
