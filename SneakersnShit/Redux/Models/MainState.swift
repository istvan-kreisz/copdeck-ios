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


enum ResellSite: String, Codable, Equatable {
    case klekt, stockx, restocks
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
    var id: String {
        name
    }
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

struct Item: Codable, Equatable, Identifiable {
    let id: String
    let ownedByCount: Int?
    let priceAlertCount: Int?
    let storeInfo: [StoreInfo]
    let storePrices: [StorePrices]
    let created: Double?
    let updated: Double?

    func storeInfo(for store: ResellSite) -> StoreInfo? {
        storeInfo.first { $0.store == store }
    }

    var stockxStoreInfo: StoreInfo? {
        storeInfo(for: .stockx)
    }
}
