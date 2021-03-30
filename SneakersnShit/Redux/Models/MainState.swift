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
        let lowestAsk: Double
        let highestBid: Double?
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
}

struct ItemStatus: Codable, Equatable {

}

//const ItemStatus = union([
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
//])

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
        self.images = item.bestStoreInfo?.imageURL.map { [$0] }
        self.created = nil
        self.updated = nil
    }
}
