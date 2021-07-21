//
//  InventoryItem.swift
//  CopDeck
//
//  Created by István Kreisz on 7/21/21.
//

import Foundation

struct InventoryItem: Codable, Equatable, Identifiable {
    enum Condition: String, Codable, CaseIterable {
        case new, used
    }

    let id: String
    let itemId: String?
    var item: Item?
    let name: String
    let purchasePrice: Double?
    let size: String
    let condition: Condition
    let notes: String?
    let created: Double?
    let updated: Double?

    func copy(with newItem: Item?) -> InventoryItem {
        var copy = self
        copy.item = newItem
        return copy
    }

    enum CodingKeys: String, CodingKey {
        case id, itemId, name, purchasePrice, size, condition, notes, created, updated
    }
}
