//
//  Optional+Extensions.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/24/21.
//

import Foundation

extension Optional where Wrapped == Double {
    func asString(defaultValue: String = "", decimalPlaces: Int = 0) -> String {
        map { String(Int($0)) } ?? defaultValue
    }

    func asPriceWithCurrency(currency: Currency) -> PriceWithCurrency? {
        map { (value: Double) in value.asPriceWithCurrency(currency: currency) }
    }
}

extension Optional where Wrapped == Int {
    var asString: String {
        map { String($0) } ?? ""
    }
}
