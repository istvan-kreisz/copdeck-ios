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
    case restorePurchases
    case purchase(package: Purchases.Package)
}

extension PaymentAction: StringRepresentable {}
