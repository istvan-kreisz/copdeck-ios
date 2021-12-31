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
    static var packagesFetchCount = 0

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

    private var loggedInAsUserWithId: String?
    private var userId: String?
    private var email: String?

    var errorsPublisher: AnyPublisher<AppError, Never> {
        errorsSubject.eraseToAnyPublisher()
    }

    override init() {
        super.init()
        if DebugSettings.shared.isInDebugMode {
            Purchases.logLevel = .debug
        }
        Purchases.configure(withAPIKey: Self.apiKey)
    }

    func setup(userId: String, userEmail: String?) {
        self.userId = userId
        self.email = userEmail
        logInIfNeeded { _ in }
    }

    func reset() {
        logOut()
        self.userId = nil
        self.email = nil
    }

    private func logOut() {
        Purchases.shared.logOut(nil)
        loggedInAsUserWithId = nil
    }

    func purchase(package: Purchases.Package) -> AnyPublisher<Void, AppError> {
        Future { [weak self] promise in
            self?.logInIfNeeded { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    Purchases.shared.purchasePackage(package) { transaction, _, error, userCancelled in
                        if let error = error {
                            promise(.failure(AppError(error: error)))
                        } else {
                            promise(.success(()))
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
        .onMain()
    }

    private func logInIfNeeded(completion: @escaping (AppError?) -> Void) {
        if let userId = userId, let email = email {
            if loggedInAsUserWithId == userId {
                completion(nil)
            } else {
                logOut()
                login(userId: userId, userEmail: email) { error in
                    if let error = error {
                        completion(AppError(error: error))
                    } else {
                        completion(nil)
                    }
                }
            }
        } else {
            completion(.notFound(val: "User"))
        }
    }

    func fetchPackages(completion: @escaping ([DiscountValue: SubscriptionPackages]) -> Void) {
        getPackages { packages in
            Self.packagesFetchCount += 1
            if let packages = packages {
                completion(packages)
            } else {
                let time: TimeInterval
                if Self.packagesFetchCount <= 3 {
                    time = 1
                } else if Self.packagesFetchCount <= 6 {
                    time = 5
                } else if Self.packagesFetchCount <= 10 {
                    time = 10
                } else {
                    time = 30
                }
                delay(time) { [weak self] in
                    self?.fetchPackages(completion: completion)
                }
            }
        }
    }

    func getPackages(completion: @escaping ([DiscountValue: SubscriptionPackages]?) -> Void) {
        Purchases.shared.offerings { offerings, error in
            if let error = error {
                log(error, logType: .error)
            }
            guard let offerings = offerings else {
                completion(nil)
                return
            }
            var result: [DiscountValue: SubscriptionPackages] = [:]
            offerings.all.forEach { id, offering in
                if let discountValue = DiscountValue.allCases.first(where: { Self.offeringId(discount: $0) == id }) {
                    result[discountValue] = .init(monthlyPackage: offering.monthly, yearlyPackage: offering.annual)
                }
            }
            completion(result)
        }
    }

    private func login(userId: String, userEmail: String?, completion: ((Error?) -> Void)?) {
        Purchases.shared.logIn(userId) { [weak self] _, created, error in
            if let error = error {
                completion?(error)
                return
            }
            if created {
                Purchases.shared.setEmail(userEmail)
            }
            self?.loggedInAsUserWithId = userId
            completion?(nil)
        }
    }
}
