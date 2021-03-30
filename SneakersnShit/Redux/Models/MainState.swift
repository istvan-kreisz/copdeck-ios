//
//  MainState.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation

// MARK: - Result

struct MainState: Equatable {
    var userId = ""
    var user: User?
    var searchResults: [Item]?
    // todo: remove?
    var selectedItem: Item?

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

    // todo: make this more generic
    func dictionary() throws -> [String: Any] {
        let encodedSelf = try JSONEncoder().encode(self)
        if let dictionary = try JSONSerialization.jsonObject(with: encodedSelf) as? [String: Any] {
            return dictionary
        } else {
            throw AppError(title: "Encoding Item Failed", message: "", error: nil)
        }
    }
}
