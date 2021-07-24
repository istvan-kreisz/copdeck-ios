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

extension Array where Element == InventoryItem {
    var allItems: [Item] {
        compactMap { $0.item }
            .reduce([:]) { dict, item in
                dict.merging([item.id: item]) { _, new in new }
            }.values.map { $0 }
    }
}
