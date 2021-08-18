//
//  InventoryItem.swift
//  CopDeck
//
//  Created by István Kreisz on 7/21/21.
//

import Foundation

struct PriceWithCurrency: Codable, Equatable {
    let price: Double
    let currencyCode: Currency.CurrencyCode

    var currencySymbol: Currency.CurrencySymbol {
        Currency.symbol(for: currencyCode)
    }

    var asString: String {
        "\(currencySymbol.rawValue)\(price.rounded(toPlaces: 0))"
    }
}

struct InventoryItem: Codable, Equatable, Identifiable {
    enum Condition: String, Codable, CaseIterable {
        case new, used
    }

    struct ListingPrice: Codable, Equatable {
        let storeId: String
        var price: PriceWithCurrency
    }

    struct SoldPrice: Codable, Equatable {
        let storeId: String?
        var price: PriceWithCurrency?
    }

    enum SoldStatus: String, Codable, Equatable {
        case none, listed, sold
    }

    let id: String
    var itemId: String?
    var name: String
    var purchasePrice: PriceWithCurrency?
    let imageURL: ImageURL?
    var size: String
    var condition: Condition
    var listingPrices: [ListingPrice] = []
    var soldPrice: SoldPrice?
    var status: SoldStatus? = InventoryItem.SoldStatus.none
    var notes: String?
    let created: Double?
    let updated: Double?

    enum CodingKeys: String, CodingKey {
        case id, itemId, name, purchasePrice, imageURL, size, condition, listingPrices, soldPrice, status, notes, created, updated
    }
}

extension InventoryItem {
    init(fromItem item: Item) {
        self.init(id: UUID().uuidString,
                  itemId: item.id,
                  name: item.name ?? "",
                  purchasePrice: item.retailPrice.asPriceWithCurrency(currency: item.currency),
                  imageURL: item.imageURL,
                  size: item.sortedSizes.first ?? "",
                  condition: .new,
                  soldPrice: nil,
                  notes: nil,
                  created: Date().timeIntervalSince1970 * 1000,
                  updated: Date().timeIntervalSince1970 * 1000)
    }

    func copy(withName name: String, itemId: String?, notes: String?) -> InventoryItem {
        var copy = self
        copy.name = name
        copy.itemId = itemId
        copy.notes = notes
        return copy
    }
}


struct InventoryItemWrapper: Equatable, Identifiable {
    var id: String { inventoryItem.id }

    let inventoryItem: InventoryItem
    let bestPrice: PriceWithCurrency?
}
