//
//  Item.swift
//  CopDeck
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

let ALLSTORES = zip(StoreId.allCases, StoreName.allCases).map { Store(id: $0, name: $1) }

struct Store: Codable, Equatable, Identifiable {
    let id: StoreId
    let name: StoreName
}

enum PriceType: String, CaseIterable, Identifiable {
    case ask, bid

    var id: String { rawValue }
}

enum FeeType: String, CaseIterable, Identifiable {
    case none, buy, sell

    var id: String { rawValue }
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

        struct InventoryItem: Codable, Equatable, Identifiable {
            let size: String
            let currencyCode: Currency.CurrencyCode
            let lowestAsk: Price?
            let highestBid: Price?
            let shoeCondition: String?
            let boxCondition: String?
            let tags: [String]

            var id: String { size }

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
    struct PriceItem {
        struct PriceInfo {
            let text: String
            let num: Double
        }

        let ask: PriceInfo
        let bid: PriceInfo
        let sellLink: String?
        let buyLink: String?
    }

    struct PriceRow: Identifiable {
        struct Price: Identifiable {
            let primaryText: String
            let secondaryText: String
            let price: Double
            let buyLink: String?
            let sellLink: String?
            let store: Store

            var id: String { store.id.rawValue }
        }

        let size: String
        let lowest: Store?
        let highest: Store?
        let prices: [Price]

        var id: String { size }
    }

    var currency: Currency {
        ALLCURRENCIES.first {
            $0.code == storePrices.first?.inventory.first?.currencyCode
        } ?? Currency(code: .usd, symbol: .usd)
    }

    private func storeInfo(for storeId: StoreId) -> StoreInfo? {
        storeInfo.first { $0.store.id == storeId }
    }

    var bestStoreInfo: StoreInfo? {
        StoreId.allCases
            .map { storeInfo(for: $0) }
            .compactMap { $0 }
            .first
    }

    private var allStorePrices: [StorePrice] {
        storePrices.filter { !$0.inventory.isEmpty }
    }

    private var sizes: [String] {
        Array(Set(allStorePrices.flatMap { store in store.inventory.map { $0.size } }))
    }

    var sortedSizes: [String] {
        sizes.sorted { a, b in
            if let aNum = a.number, let bNum = b.number {
                return aNum < bNum
            } else {
                return true
            }
        }
    }

    private func price(size: String, storeId: StoreId, feeType: FeeType, currency: Currency) -> PriceItem {
        let prices = allStorePrices.first(where: { $0.store.id == storeId })?.inventory.first(where: { $0.size == size })
        let storeInfo = storeInfo.first(where: { $0.store.id == storeId })
        let ask = prices?.lowestAsk
        let bid = prices?.highestBid
        var askPrice = ask?.noFees
        var bidPrice = bid?.noFees
        if feeType != .none {
            askPrice = feeType == .buy ? ask?.withBuyerFees : ask?.withSellerFees
            bidPrice = feeType == .buy ? bid?.withBuyerFees : bid?.withSellerFees
        }
        let askInfo: PriceItem.PriceInfo = askPrice.map {
            PriceItem.PriceInfo(text: currency.symbol.rawValue + " \($0)", num: $0)
        } ?? PriceItem.PriceInfo(text: "-", num: 0)
        let bidInfo: PriceItem.PriceInfo = bidPrice.map {
            PriceItem.PriceInfo(text: currency.symbol.rawValue + " \($0)", num: $0)
        } ?? PriceItem.PriceInfo(text: "-", num: 0)

        var sizeQuery = ""
        if let sizeNum = size.number {
            sizeQuery = storeId.rawValue == "goat" || storeId.rawValue == "stockx" ? "size=\(sizeNum)" : ""
        }
        return PriceItem(ask: askInfo, bid: bidInfo, sellLink: storeInfo?.sellUrl, buyLink: (storeInfo?.buyUrl).map { $0 + sizeQuery })
    }

    private func prices(size: String, priceType: PriceType, feeType: FeeType) -> PriceRow {
        let prices = ALLSTORES.map { store -> PriceRow.Price in
            let p = price(size: size, storeId: store.id, feeType: feeType, currency: currency)
            return PriceRow.Price(primaryText: priceType == .ask ? p.ask.text : p.bid.text,
                                  secondaryText: priceType == .ask ? p.bid.text : p.ask.text,
                                  price: priceType == .ask ? p.ask.num : p.bid.num,
                                  buyLink: p.buyLink,
                                  sellLink: p.sellLink,
                                  store: store)
        }
        let realPrices = prices.filter { $0.primaryText != "-" }
        var lowest: Store?
        var highest: Store?
        if !realPrices.isEmpty {
            lowest = realPrices.min(by: { $0.price < $1.price })?.store
            highest = realPrices.max(by: { $0.price < $1.price })?.store
        }
        return PriceRow(size: size, lowest: lowest, highest: highest, prices: prices)
    }

    func allPriceRows(priceType: PriceType, feeType: FeeType) -> [PriceRow] {
        sortedSizes.map { prices(size: $0, priceType: priceType, feeType: feeType) }
    }
}

extension Item {
    static let sample =
        Item(id: "GHVDY45",
             storeInfo: [Item.StoreInfo(name: "Stockx",
                                        sku: "GHVDY45",
                                        slug: "",
                                        retailPrice: 234,
                                        brand: "Adidas",
                                        store: Store(id: .stockx, name: .StockX),
                                        imageURL: "",
                                        url: "",
                                        sellUrl: "",
                                        buyUrl: "",
                                        productId: "")],
             storePrices: [],
             ownedByCount: 0,
             priceAlertCount: 0,
             created: 0,
             updated: 0,
             name: "yolo",
             retailPrice: 12,
             imageURL: nil)
}
