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

//    https://stackoverflow.com/questions/35700281/date-format-in-swift
    var asDateFormat1: String {
        let publishedDate = Date(timeIntervalSince1970: self / 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: publishedDate)
    }
    
    var asDateFormat2: String {
        let joinedDate = Date(timeIntervalSince1970: self / 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: joinedDate)
    }
}
