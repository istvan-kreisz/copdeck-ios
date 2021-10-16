//
//  PaymentAction.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/29/21.
//

import Foundation


enum PaymentAction {
    case applyReferralCode(_ code: String, completion: ((Result<Void, AppError>) -> Void)?)
}

extension PaymentAction: StringRepresentable {}
