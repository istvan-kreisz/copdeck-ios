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

enum DiscountValue: CaseIterable, Equatable {
    case noDiscount, d10, d20, d30, d40

    var value: Int {
        switch self {
        case .noDiscount:
            return 0
        case .d10:
            return 10
        case .d20:
            return 20
        case .d30:
            return 30
        case .d40:
            return 40
        }
    }

    var valueString: String { "\(value)" }
}

class DefaultPaymentService: NSObject, PaymentService {
    static let entitlementsId = "pro"
    static let apiKey = "vkJAtxOkCMEORPnQDmuEwtoUBuHDUMSu"
    static let iosBetaTesterDiscount: DiscountValue = .d30

    static func offeringId(discount: DiscountValue) -> String {
        discount == .noDiscount ? "pro" : "pro" + discount.valueString
    }

    static func productId(discount: DiscountValue, packageType: Purchases.PackageType) -> String {
        if discount == .noDiscount {
            return packageType == Purchases.PackageType.monthly ? "copdeckPro" : "copdeckProAnnual"
        } else {
            return packageType == Purchases.PackageType.monthly ? "copdeckPro_\(discount.valueString)" : "copdeckProAnnual\(discount.valueString)"
        }
    }

    private let errorsSubject = PassthroughSubject<AppError, Never>()
    private let packagesSubject = CurrentValueSubject<[DiscountValue: SubscriptionPackages]?, Never>(nil)

    private var isLoggedIn = false
    private var userId: String?
    private var email: String?

    var errorsPublisher: AnyPublisher<AppError, Never> {
        errorsSubject.eraseToAnyPublisher()
    }

    var packagesPublisher: AnyPublisher<[DiscountValue: SubscriptionPackages]?, Never> {
        packagesSubject.eraseToAnyPublisher()
    }

    override init() {
        super.init()
        if DebugSettings.shared.isInDebugMode {
            Purchases.logLevel = .debug
        }
        Purchases.configure(withAPIKey: Self.apiKey)

        getPackages {}
    }

    func setup(userId: String, userEmail: String?) {
        self.userId = userId
        self.email = userEmail
        if packagesSubject.value?.isEmpty != false || packagesSubject.value?.isEmpty != false {
            fetchPackages(completion: nil)
        } else {
            login(userId: userId, userEmail: userEmail)
        }
    }

    func reset() {
        Purchases.shared.logOut(nil)
        isLoggedIn = false
        self.userId = nil
        self.email = nil
    }

    func purchase(package: Purchases.Package) -> AnyPublisher<Void, AppError> {
        Future { promise in
            Purchases.shared.purchasePackage(package) { transaction, _, error, userCancelled in
                if let error = error {
                    promise(.failure(AppError(error: error)))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
        .onMain()
    }

    private func logInIfNeeded() {
        if let userId = userId, let email = email, !isLoggedIn {
            login(userId: userId, userEmail: email)
        }
    }

    func fetchPackages(completion: (() -> Void)?) {
        guard AppStore.default.state.globalState.allPackages.isEmpty else {
            logInIfNeeded()
            completion?()
            return
        }
        getPackages { [weak self] in
            self?.logInIfNeeded()
            completion?()
        }
    }

    func getPackages(completion: (() -> Void)?) {
        Purchases.shared.offerings { [weak self] offerings, error in
//            error.map { self?.errorsSubject.send(AppError(error: $0)) }
            guard let offerings = offerings else {
                completion?()
                return
            }
            var result: [DiscountValue: SubscriptionPackages] = [:]
            offerings.all.forEach { id, offering in
                if let discountValue = DiscountValue.allCases.first(where: { Self.offeringId(discount: $0) == id }) {
                    result[discountValue] = .init(monthlyPackage: offering.monthly, yearlyPackage: offering.annual)
                }
            }
            self?.packagesSubject.send(result)
            completion?()
        }
    }

    private func login(userId: String, userEmail: String?) {
        Purchases.shared.logIn(userId) { [weak self] _, created, error in
            if let error = error {
                self?.errorsSubject.send(AppError(error: error))
                return
            }
            if created {
                Purchases.shared.setEmail(userEmail)
            }
            self?.isLoggedIn = true
        }
    }
}
