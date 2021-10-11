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
    static let `default` = ExchangeRates(usd: 1.1574, gbp: 0.84878, chf: 1.0722, nok: 9.888, updated: Date.serverDate)
}
