//
//  Double+Extensions.swift
//  CopDeck
//
//  Created by István Kreisz on 7/11/21.
//

import Foundation

extension Double {
    func rounded(toPlaces places: Int) -> String {
        String(format: "%.\(places)f", self)
    }

    func isOlderThan(minutes: Double) -> Bool {
        (Date().timeIntervalSince1970 - self / 1000) / 60 > minutes
    }

    func asPriceWithCurrency(currency: Currency) -> PriceWithCurrency {
        PriceWithCurrency(price: self, currencyCode: currency.code)
    }
}
