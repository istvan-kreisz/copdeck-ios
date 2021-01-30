//
//  IAPManager.swift
//  InfluTrader
//
//  Created by István Kreisz on 1/29/21.
//

import Foundation
import StoreKit
import Combine

// todo: refactor
class IAPHelper: NSObject {
    
    static let shared = IAPHelper()
    
    private var userId: String? {
        UserDefaults.standard.string(forKey: "userId")
    }
    private var userDefaultsId: String? {
        userId.map { Constants.didBuyPremiumKey + $0 }
    }

    var didBuyPremium: Bool {
        userDefaultsId.map { UserDefaults.standard.bool(forKey: $0) } ?? false
    }
    lazy var didBuyPremiumSubject = CurrentValueSubject<Bool, Never>(didBuyPremium)
    
    func updateDidBuyPremium() {
        didBuyPremiumSubject.send(didBuyPremium)
    }
    
    let loadingState = CurrentValueSubject<Bool, Never>(false)

    private var products: [String: SKProduct?] = [:]
    private var productsRequest: SKProductsRequest?
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        requestProducts()
    }

    private func requestProducts() {
        productsRequest?.cancel()
        productsRequest = SKProductsRequest(productIdentifiers: [Constants.premium])
        productsRequest?.delegate = self
        productsRequest?.start()
    }

    private enum Constants {
        static let premium = "istvankreisz.ToDo.premium"
        static let didBuyPremiumKey = "didBuyPremium"
    }
}

// MARK: - StoreKit API

extension IAPHelper {
    func buyPremium() {
        loadingState.send(true)
        guard let storedProduct = products[Constants.premium], let product = storedProduct else { return }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func restorePurchases() {
        loadingState.send(true)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    var canMakePayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
}

// MARK: - SKProductsRequestDelegate

extension IAPHelper: SKProductsRequestDelegate {
    func productsRequest(_: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.products.forEach { [unowned self] in self.products[$0.productIdentifier] = $0 }
    }
}

// MARK: - SKPaymentTransactionObserver

extension IAPHelper: SKPaymentTransactionObserver {
    public func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased: complete(transaction: transaction)
            case .failed: fail(transaction: transaction)
            case .restored: restore(transaction: transaction)
            case .deferred: continue
            case .purchasing: continue
            @unknown default: continue
            }
            loadingState.send(false)
        }
    }

    private func complete(transaction: SKPaymentTransaction) {
        savePurchasedState()
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func restore(transaction: SKPaymentTransaction) {
        savePurchasedState()
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func fail(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func savePurchasedState() {
        userDefaultsId.map { UserDefaults.standard.set(true, forKey: $0) }
        didBuyPremiumSubject.send(true)
    }
}
