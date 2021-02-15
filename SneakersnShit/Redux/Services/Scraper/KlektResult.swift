//
//  KlektResult.swift
//  SneakersnShit
//
//  Created by István Kreisz on 2/15/21.
//

import Foundation

// MARK: - Welcome

struct KlektResult: Codable {
    let data: DataClass
}

// MARK: - DataClass

struct DataClass: Codable {
    let id: Int
    let brand: String
    let title: String
    let created: String
    let updated: String
    let description: String
    let categoryId: Int
    let rankingIndex: Int
    let salesIndex: Int
    let imageURL: String
    let tags: [String]
    let uri: String
    let lowestPrice: Int
    let lowestNddPrice: Int
    let highestPrice: Int
    let highestNddPrice: Int
    let availableSizes: [String]
    let baseCurrency: Currency
    let numberAvailableInventory: Int
    let inventory: [Inventory]
}

enum Currency: String, Codable {
    case eur = "EUR"
}

// MARK: - Inventory

struct Inventory: Codable {
    let inventoryId, itemId, userId: Int
    let size: String
    let status: Status
    let currency: Currency
    let price, basePrice, nextDayDeliveryPrice: Int
    let pubDate, originalPubDate: String
    let purchaseURI: String
    let purchaseURL: String
    let inStock: Int

    enum CodingKeys: String, CodingKey {
        case inventoryId
        case itemId
        case userId
        case size, status, currency, price, basePrice, nextDayDeliveryPrice, pubDate, originalPubDate, purchaseURI, purchaseURL
        case inStock = "in-stock"
    }
}

enum Status: String, Codable {
    case available = "available"
}
