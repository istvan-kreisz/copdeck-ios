//
//  Item.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/6/21.
//

import Foundation

enum StoreId: String, Codable, CaseIterable {
    case stockx, klekt, goat
}

enum StoreName: String, Codable, CaseIterable {
    case StockX, Klekt, GOAT
}

struct Store: Codable, Equatable {
    let id: StoreId
    let name: StoreName
}

struct Item: Codable, Equatable, Identifiable {
    let id: String
    let storeInfo: [StoreInfo]
    let storePrices: [StorePrice]
    let ownedByCount: Int?
    let priceAlertCount: Int?
    let created: Int?
    let updated: Int?
    let name: String?
    let retailPrice: Double?
    let imageURL: ImageURL?

    struct StoreInfo: Codable, Equatable, Identifiable {
        let name: String
        let sku: String
        let slug: String
        let retailPrice: Double?
        let brand: String
        let store: Store
        let imageURL: String?
        let url: String
        let sellUrl: String
        let buyUrl: String
        let productId: String?

        var id: String { name }
    }

    struct ImageURL: Codable, Equatable {
        let url: String
        let store: Store
    }

    struct StorePrice: Codable, Equatable {
        let retailPrice: Double?
        let store: Store
        let inventory: [InventoryItem]

        struct InventoryItem: Codable, Equatable {
            let size: String
            let currencyCode: Currency.CurrencyCode
            let lowestAsk: Price?
            let highestBid: Price?
            let shoeCondition: String?
            let boxCondition: String?
            let tags: [String]

            var sizeTrimmed: String? {
                let numString = size.trimmingCharacters(in: CharacterSet.letters.union(CharacterSet.whitespacesAndNewlines))
                return Double(numString) != nil ? numString : nil
            }

            struct Price: Codable, Equatable {
                let noFees: Double
                let withSellerFees: Double?
                let withBuyerFees: Double?
            }
        }
    }
}

extension Item {
    func storeInfo(for storeId: StoreId) -> StoreInfo? {
        storeInfo.first { $0.store.id == storeId }
    }

    var bestStoreInfo: StoreInfo? {
        StoreId.allCases
            .map { storeInfo(for: $0) }
            .compactMap { $0 }
            .first
    }

    // todo: update logic
    var priceTable: [StorePrice] {
        []
//        if let sizes = storePrices.sorted(by: { prices1, prices2 in
//            prices1.inventory.count < prices2.inventory.count
//        })
//            .last?.inventory
//            .compactMap({ $0.sizeTrimmed }) {
//            return Store.allCases.map { site -> StorePrices in
//                StorePrices(store: site, retailPrice: nil, inventory: sizes.map { String($0) }.map { size -> StorePrices.InventoryElement in
//                    print(size)
//                    let price = storePrices.first(where: { $0.store == site })?.inventory.first(where: { $0.sizeTrimmed?.contains(size) == true })?.lowestAsk
//                    return StorePrices.InventoryElement(size: size, currency: "USD", lowestAsk: price, highestBid: nil)
//                })
//            }
//        } else {
//            return []
//        }
    }
}

struct PriceTableItem {
    let size: String
    let price: Double
    let store: Store
}

struct PriceTable {
    let prices: PriceTableItem
}
