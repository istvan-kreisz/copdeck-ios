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
        let storeId: String
        var price: Int
    }
    struct SoldPrice: Codable, Equatable {
        let storeId: String?
        var price: Double?
    }

    let id: String
    let itemId: String?
    var name: String
    var purchasePrice: Double?
    let imageURL: String?
    var size: String
    var condition: Condition
    var listingPrices: [ListingPrice] = []
    var soldPrice: SoldPrice?
    var notes: String?
    let created: Double?
    let updated: Double?

    enum CodingKeys: String, CodingKey {
        case id, itemId, name, purchasePrice, imageURL, size, condition, listingPrices, soldPrice, notes, created, updated
    }
}

extension InventoryItem {
    init(fromItem item: Item) {
        self.init(id: UUID().uuidString,
                  itemId: item.id,
                  name: item.name ?? "",
                  purchasePrice: nil,
                  imageURL: item.imageURL?.url,
                  size: item.sortedSizes.first ?? "",
                  condition: .new,
                  soldPrice: nil,
                  notes: nil,
                  created: Date().timeIntervalSince1970 * 1000,
                  updated: Date().timeIntervalSince1970 * 1000)
    }
}
