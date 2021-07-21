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
}
