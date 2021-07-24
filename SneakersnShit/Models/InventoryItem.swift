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
    struct ListingPrice: Codable, Equatable {
        let storeId: StoreId
        var price: Int
    }
    struct SoldPrice: Codable, Equatable {
        let storeId: StoreId?
        var price: Double?
    }

    let id: String
    let itemId: String?
    var item: Item?
    var name: String
    var purchasePrice: Double?
    var size: String
    var condition: Condition
    var listingPrices: [ListingPrice] = []
    var soldPrice: SoldPrice?
    var notes: String?
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

extension InventoryItem {
    init(fromItem item: Item) {
        self.init(id: UUID().uuidString,
                  itemId: item.id,
                  item: item,
                  name: item.name ?? "",
                  purchasePrice: nil,
                  size: item.sortedSizes.first ?? "",
                  condition: .new,
                  soldPrice: nil,
                  notes: nil,
                  created: Date().timeIntervalSince1970,
                  updated: Date().timeIntervalSince1970)
    }
}
