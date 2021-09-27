//
//  Optional+Extensions.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/24/21.
//

import Foundation

extension Optional where Wrapped == Double {
    func asString(defaultValue: String = "") -> String {
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

extension Optional where Wrapped: Sequence {
    func asArray() -> [Wrapped.Element] {
        map { (sequence: Wrapped) -> [Wrapped.Element] in
            if let array = sequence as? [Wrapped.Element] {
                return array
            } else {
                return Array(sequence)
            }
        } ?? []
    }
}

extension Optional where Wrapped: Collection {
    var isEmpty: Bool {
        self?.isEmpty ?? true
    }
}
