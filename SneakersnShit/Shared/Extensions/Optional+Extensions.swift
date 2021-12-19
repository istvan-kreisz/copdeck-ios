//
//  Optional+Extensions.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/24/21.
//

import Foundation

extension Optional where Wrapped == Double {
    func asString(defaultValue: String = "", convertZeroToEmptyString: Bool = false) -> String {
        map {
            let num = Int($0)
            return (convertZeroToEmptyString && num == 0) ? "" : String(num)
        } ?? defaultValue
    }

    func asPriceWithCurrency(currency: Currency) -> PriceWithCurrency? {
        map { (value: Double) in value.asPriceWithCurrency(currency: currency) }
    }

    var serverDate: Date? {
        map { Date(timeIntervalSince1970: $0 / 1000) }
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
