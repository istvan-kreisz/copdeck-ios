//
//  MainState.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation

// todo: refactor

struct MainState: Equatable {
    var userId = ""
    var user: User?
    var searchResults: [Item]?
    var selectedItem: Item?
    var inventoryItems: [InventoryItem] = []

    enum CodingKeys: String, CodingKey {
        case user
    }
}

struct User: Codable, Equatable {
    let id: String
    let name: String?
    let created: Double?
    let updated: Double?
}

enum ResellSite: String, Codable, Equatable, CaseIterable {
    case stockx, klekt, restocks
}

struct StoreInfo: Codable, Equatable {
    let name: String
    let sku: String
    let slug: String
    let retailPrice: Double?
    let imageURL: String?
    let referer: String?
    let brand: String
    let store: ResellSite
}

extension StoreInfo: Identifiable {
    var id: String { name }
}

struct StorePrices: Codable, Equatable {
    struct InventoryElement: Codable, Equatable {
        let size: String
        let currency: String
        let lowestAsk: Int?
        let highestBid: Int?

        var sizeTrimmed: String? {
            let numString = size.trimmingCharacters(in: CharacterSet.letters.union(CharacterSet.whitespacesAndNewlines))
            return Double(numString) != nil ? numString : nil
        }
    }

    let store: ResellSite
    let retailPrice: Double?
    let inventory: [InventoryElement]
}

extension StorePrices: Identifiable {
    var id: String { store.rawValue }
}

extension StorePrices.InventoryElement: Identifiable {
    var id: String { size }
}

struct Item: Codable, Equatable, Identifiable {
    let id: String
    let ownedByCount: Int?
    let priceAlertCount: Int?
    let storeInfo: [StoreInfo]
    var storePrices: [StorePrices]
    let created: Double?
    let updated: Double?

    func storeInfo(for store: ResellSite) -> StoreInfo? {
        storeInfo.first { $0.store == store }
    }

    var bestStoreInfo: StoreInfo? {
        ResellSite.allCases
            .map { storeInfo(for: $0) }
            .compactMap { $0 }
            .first
    }

    struct PriceTableItem {
        let size: String
        let price: Double
        let store: ResellSite
    }

    struct PriceTable {
        let prices: PriceTableItem
    }

    // todo: update logic
    var priceTable: [StorePrices] {
        if let sizes = storePrices.sorted(by: { prices1, prices2 in
            prices1.inventory.count < prices2.inventory.count
        })
            .last?.inventory
            .compactMap({ $0.sizeTrimmed }) {
            return ResellSite.allCases.map { site -> StorePrices in
                StorePrices(store: site, retailPrice: nil, inventory: sizes.map { String($0) }.map { size -> StorePrices.InventoryElement in
                    print(size)
                    let price = storePrices.first(where: { $0.store == site })?.inventory.first(where: { $0.sizeTrimmed?.contains(size) == true })?.lowestAsk
                    return StorePrices.InventoryElement(size: size, currency: "USD", lowestAsk: price, highestBid: nil)
                })
            }
        } else {
            return []
        }
    }
}

struct ItemStatus: Codable, Equatable, Hashable {}

// const ItemStatus = union([
//    object({
//        listingPrices: defaulted(
//            array(
//                object({
//                    store: Store,
//                    price: number(),
//                })
//            ),
//            () => []
//        ),
//    }),
//    object({
//        sellingPrice: Optional(number()),
//        store: Optional(Store),
//    }),
// ])

enum Condition: String, Codable, Equatable {
    case new, used
}

struct InventoryItem: Codable, Equatable, Identifiable {
    let id: String
    let itemId: String?
    let name: String
    let purchasePrice: Double?
    let size: String
    let condition: Condition
    let status: ItemStatus?
    let notes: String?
    let images: [String]?
    let created: Double?
    let updated: Double?
}

extension InventoryItem: Hashable {}

extension InventoryItem {
    init(from item: Item) {
        self.id = UUID().uuidString
        self.itemId = item.id
        self.name = item.bestStoreInfo?.name ?? ""
        self.purchasePrice = item.bestStoreInfo?.retailPrice
        self.size = "US 10"
        self.condition = .new
        self.status = nil
        self.notes = nil
        self.images = item.storeInfo.first(where: { $0.imageURL != nil })?.imageURL.map { [$0] }
        self.created = nil
        self.updated = nil
    }
}
