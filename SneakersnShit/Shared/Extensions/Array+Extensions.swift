//
//  Array+Extensions.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation

extension Array where Element: Numeric {
    func sum() -> Element {
        reduce(0, +)
    }
}

extension Array {
    func first(n: Int) -> [Element] {
        Array(prefix(n))
    }
}
