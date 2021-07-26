//
//  Currency.swift
//  CopDeck
//
//  Created by István Kreisz on 7/6/21.
//

import Foundation

struct Currency: Codable, Equatable {
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

let ALLSELECTABLECURRENCYCODES: [Currency.CurrencyCode] = [.eur, .usd, .gbp]
let ALLSELECTABLECURRENCYSYMBOLS: [Currency.CurrencySymbol] = [.eur, .usd, .gbp]

let ALLCURRENCIES = zip(ALLSELECTABLECURRENCYCODES, ALLSELECTABLECURRENCYSYMBOLS).map { Currency(code: $0, symbol: $1) }
