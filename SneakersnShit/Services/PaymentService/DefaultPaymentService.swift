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
    static var packagesFetchCount = 0
    static let offeringId: String = "pro"

    static func productId(packageType: Purchases.PackageType) -> String {
        packageType == Purchases.PackageType.monthly ? "copdeckPro" : "copdeckProAnnual"
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

    func fetchPackages(completion: @escaping (SubscriptionPackages?) -> Void) {
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

    func getPackages(completion: @escaping (SubscriptionPackages?) -> Void) {
        Purchases.shared.offerings { offerings, error in
            if let error = error {
                log(error, logType: .error)
            }
            guard let offerings = offerings else {
                completion(nil)
                return
            }
            if let offering = offerings.all.filter({ id, _ in id == Self.offeringId }).map({ id, offering in offering }).first {
                completion(.init(monthlyPackage: offering.monthly, yearlyPackage: offering.annual))
            } else {
                completion(nil)
            }
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
            AppStore.default.state.globalState.loggedInToRevenueCat = true
            completion?(nil)
        }
    }
}
