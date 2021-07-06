//
//  Item.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/6/21.
//

import Foundation

// MARK: - Welcome

struct SItem: Codable {
    let id: String
    let storeInfo: [SStoreInfo]
    let storePrices: [StorePrice]
    let ownedByCount: Int?
    let priceAlertCount: Int?
    let created: Int?
    let updated: Int?
    let name: String?
    let retailPrice: Double?
    let imageURL: ImageURL?
}

struct ImageURL: Codable {
    let url: String
    let store: SStore
}

struct SStore: Codable {
    let id: String
    let name: String
}

struct SStoreInfo: Codable {
    let name: String
    let sku: String
    let slug: String
    let retailPrice: Double?
    let brand: String
    let store: SStore
    let imageURL: String?
    let url: String
    let sellUrl: String
    let buyUrl: String
    let productId: String?
}

struct StorePrice: Codable {
    let retailPrice: Double?
    let store: SStore
    let inventory: [SInventoryItem]
}

// MARK: - Inventory

struct SInventoryItem: Codable {
    let size: String
    let currencyCode: CurrencyCode
    let lowestAsk: Price?
    let highestBid: Price?
    let shoeCondition: String?
    let boxCondition: String?
    let tags: [String]

    struct Price: Codable {
        let noFees: Double
        let withSellerFees: Double?
        let withBuyerFees: Double?
    }
}

enum CurrencyCode: String, Codable {
    case gbp = "GBP"
    case usd = "USD"
    case eur = "EUR"
    case nok = "NOK"
}
