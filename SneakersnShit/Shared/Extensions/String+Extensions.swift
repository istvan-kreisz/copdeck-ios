//
//  String+Extensions.swift
//  CopDeck
//
//  Created by István Kreisz on 7/11/21.
//

import Foundation

extension String {
    var number: Double? {
        let sanitized = self
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "US", with: "")
            .replacingOccurrences(of: "⅓", with: ".33")
            .replacingOccurrences(of: "⅔", with: ".66")
            .replacingOccurrences(of: "½", with: ".5")
        return Double(sanitized.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .filter { Double($0) != nil }
            .joined(separator: "."))
    }

    func fuzzyMatch(_ needle: String) -> Bool {
        if needle.isEmpty { return true }
        var remainder: String.SubSequence = needle[...]
        for char in self {
            let currentChar = remainder[remainder.startIndex]
            if char == currentChar {
                remainder.removeFirst()
                if remainder.isEmpty { return true }
            }
        }
        return false
    }

    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }

    func asSize(gender: Gender?, brand: Brand?) -> String {
        convertSize(from: .US,
                    to: AppStore.default.state.settings.shoeSize,
                    size: self,
                    gender: gender,
                    brand: brand)
    }

    func asSize(of item: Item?) -> String {
        asSize(gender: item?.genderCalculated, brand: item?.brandCalculated)
    }

    func asSize(of inventoryItem: InventoryItem?) -> String {
        asSize(gender: inventoryItem?.genderCalculated, brand: inventoryItem?.brandCalculated)
    }
}

extension Array where Element == String {
    func asSizes(gender: Gender?, brand: Brand?) -> [String] {
        convertSizes(from: .US,
                     to: AppStore.default.state.settings.shoeSize,
                     sizes: self,
                     gender: gender,
                     brand: brand)
    }

    func asSizes(of item: Item?) -> [String] {
        asSizes(gender: item?.genderCalculated, brand: item?.brandCalculated)
    }

    func asSizes(of inventoryItem: InventoryItem?) -> [String] {
        asSizes(gender: inventoryItem?.genderCalculated, brand: inventoryItem?.brandCalculated)
    }
}
