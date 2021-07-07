//
//  Currency.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/6/21.
//

import Foundation

struct Currency: Codable {
    let code: CurrencyCode
    let symbol: String

    enum CurrencyCode: String, Codable, Equatable {
        case gbp = "GBP"
        case usd = "USD"
        case eur = "EUR"
        case nok = "NOK"
    }
}
