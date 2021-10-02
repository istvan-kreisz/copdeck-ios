//
//  ExchangeRates.swift
//  CopDeck
//
//  Created by István Kreisz on 7/6/21.
//

import Foundation

struct ExchangeRates: Codable, Equatable {
    let usd: Double
    let gbp: Double
    let chf: Double
    let nok: Double
    let updated: Double?
}

extension ExchangeRates {
    static let `default` = ExchangeRates(usd: 1.2125, gbp: 0.8571, chf: 1.0883, nok: 10.0828, updated: Date.serverDate)
}
