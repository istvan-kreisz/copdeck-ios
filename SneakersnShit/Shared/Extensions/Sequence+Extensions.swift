//
//  Sequence+Extensions.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation

extension Sequence where Element: Numeric {
    func sum() -> Element {
        reduce(0, +)
    }
}

extension Sequence {
    func first(n: Int) -> [Element] {
        Array(prefix(n))
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

extension Sequence where Element: Identifiable, Element.ID == String {
    func uniqueById() -> [Element] {
        var uniqueElements: [Element] = []
        self.forEach { element in
            if !uniqueElements.contains(where: { $0.id == element.id }) {
                uniqueElements.append(element)
            }
        }
        return uniqueElements
    }
}
