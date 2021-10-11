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

    enum CurrencyCode: String, Codable, Equatable, CaseIterable, Hashable {
        case gbp = "GBP"
        case usd = "USD"
        case eur = "EUR"
        case nok = "NOK"
        case chf = "CHF"
    }

    enum CurrencySymbol: String, Codable, Equatable, CaseIterable, Hashable {
        case gbp = "£"
        case usd = "$"
        case eur = "€"
        case nok = "NOK"
        case chf = "CHF"
    }

    static func symbol(for code: CurrencyCode) -> CurrencySymbol {
        switch code {
        case .gbp:
            return .gbp
        case .usd:
            return .usd
        case .eur:
            return .eur
        case .nok:
            return .nok
        case .chf:
            return .chf
        }
    }

    static func currency(withSymbol symbol: String) -> Currency? {
        if let symbol = Currency.CurrencySymbol(rawValue: symbol),
           let currency = ALLCURRENCIES.first(where: { $0.symbol == symbol }) {
            return currency
        } else {
            return nil
        }
    }
    
    static func convert(from currency1: CurrencyCode, to currency2: CurrencyCode, exchangeRates: ExchangeRates) -> Double? {
        if currency1 == currency2 { return 1 }
        let rates: [CurrencyCode: Double] = [.gbp: exchangeRates.gbp, .usd: exchangeRates.usd, .eur: 1, .nok: exchangeRates.nok, .chf: exchangeRates.chf]
        guard let fromRate = rates[currency1], let toRate = rates[currency2] else { return nil }
        return toRate / fromRate
    }
}

let ALLSELECTABLECURRENCYCODES: [Currency.CurrencyCode] = [.eur, .usd, .gbp]
let ALLSELECTABLECURRENCYSYMBOLS: [Currency.CurrencySymbol] = [.eur, .usd, .gbp]

let ALLCURRENCIES = zip(ALLSELECTABLECURRENCYCODES, ALLSELECTABLECURRENCYSYMBOLS).map { Currency(code: $0, symbol: $1) }
