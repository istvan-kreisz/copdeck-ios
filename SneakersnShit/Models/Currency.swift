//
//  Currency.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/6/21.
//

import Foundation

struct Currency: Codable {
    let code: CurrencyCode
    let symbol: CurrencySymbol

    enum CurrencyCode: String, Codable, Equatable, CaseIterable {
        case gbp = "GBP"
        case usd = "USD"
        case eur = "EUR"
        case nok = "NOK"
        case chf = "CHF"
    }

    enum CurrencySymbol: String, Codable, Equatable, CaseIterable {
        case gbp = "£"
        case usd = "$"
        case eur = "€"
        case nok = "NOK"
        case chf = "CHF"
    }
}

let ALLCURRENCIES = zip(Currency.CurrencyCode.allCases, Currency.CurrencySymbol.allCases).map { Currency(code: $0, symbol: $1) }
