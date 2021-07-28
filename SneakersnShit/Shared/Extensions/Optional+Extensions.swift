//
//  Optional+Extensions.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/24/21.
//

import Foundation

extension Optional where Wrapped == Double {
    var asString: String {
        map { String(Int($0)) } ?? ""
    }

    func asPriceWithCurrency(currency: Currency) -> PriceWithCurrency? {
        map { $0.asPriceWithCurrency(currency: currency) }
    }
}

extension Optional where Wrapped == Int {
    var asString: String {
        map { String($0) } ?? ""
    }
}
