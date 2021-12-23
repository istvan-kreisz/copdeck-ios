//
//  PaymentAction.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/29/21.
//

import Foundation
import Purchases

enum PaymentAction {
    case applyReferralCode(_ code: String, completion: ((Result<Void, AppError>) -> Void)?)
    case restorePurchases(completion: ((Result<Void, AppError>) -> Void)?)
    case fetchPackages
    case purchase(package: Purchases.Package)
    case showPaymentView(show: Bool)
}

extension PaymentAction: StringRepresentable {}
