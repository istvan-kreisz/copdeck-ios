//
//  String+Extensions.swift
//  CopDeck
//
//  Created by István Kreisz on 7/11/21.
//

import Foundation

extension String {
    var number: Double? {
        Double(components(separatedBy: CharacterSet.decimalDigits.inverted)
            .filter { Double($0) != nil }
            .joined(separator: "."))
    }

    func fuzzyMatch(_ needle: String) -> Bool {
        if needle.isEmpty { return true }
        var remainder = needle[...]
        for char in self {
            if char == remainder[remainder.startIndex] {
                remainder.removeFirst()
                if remainder.isEmpty { return true }
            }
        }
        return false
    }
}
