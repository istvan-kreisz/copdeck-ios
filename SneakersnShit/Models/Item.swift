//
//  Item.swift
//  CopDeck
//
//  Created by István Kreisz on 7/6/21.
//

import Foundation

enum StoreId: String, Codable, CaseIterable, Hashable {
    case stockx, klekt, goat, restocks
}

enum StoreName: String, Codable, CaseIterable, Hashable {
    case StockX, Klekt, GOAT, Restocks
}

let ALLSTORES: [Store] = zip(StoreId.allCases, StoreName.allCases).map { (id: StoreId, name: StoreName) in Store(id: id, name: name) }

let ALLSTORESWITHOTHER: [GenericStore] = ALLSTORES
    .map { (store: Store) in GenericStore(id: store.id.rawValue, name: store.name.rawValue) } + [GenericStore(id: "other", name: "Other")]

let ALLSHOESIZESUS = (6 ... 36)
    .reversed()
    .filter { $0 > 26 ? $0.isMultiple(of: 2) : true }
    .map { "US \((Double($0) * 0.5).rounded(toPlaces: $0 % 2 == 1 ? 1 : 0))" }
var ALLSHOESIZES: [String] { ALLSHOESIZESUS.map { convertSize(from: .US, to: AppStore.default.state.settings.shoeSize, size: $0) }.uniqued() }

struct GenericStore: Codable, Equatable, Identifiable {
    let id: String
    let name: String
}

struct Store: Codable, Equatable, Identifiable, Hashable {
    let id: StoreId
    let name: StoreName
}

extension Store {
    static func store(withName name: String) -> Store? {
        ALLSTORES.first(where: { $0.name.rawValue == name })
    }

    static func store(withId id: StoreId) -> Store? {
        ALLSTORES.first(where: { $0.id == id })
    }

    static func store(withId id: String) -> Store? {
        ALLSTORES.first(where: { $0.id.rawValue == id })
    }
}

enum PriceType: String, CaseIterable, Identifiable, EnumCodable {
    case Ask, Bid

    var id: String { rawValue }
}

enum FeeType: String, CaseIterable, Identifiable, EnumCodable {
    case None, Buy, Sell

    var id: String { rawValue }
}

struct ImageURL: Codable, Equatable, Hashable {
    let url: String
    let store: Store?

    var URL: URL? {
        Foundation.URL(string: url)
    }
}

struct Item: Codable, Equatable, Identifiable, Hashable, ModelWithDate {
    let id: String
    var storeInfo: [StoreInfo]
    var storePrices: [StorePrice]
    var created: Double?
    var updated: Double?
    let name: String?
    var retailPrice: Double?
    let imageURL: ImageURL?

    struct StoreInfo: Codable, Equatable, Identifiable, Hashable {
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
        let gender: Gender?

        var id: String { name }
    }

    struct StorePrice: Codable, Equatable, Hashable {
        let retailPrice: Double?
        let store: Store
        var inventory: [StoreInventoryItem]
        let currencyCode: Currency.CurrencyCode?

        struct StoreInventoryItem: Codable, Equatable, Identifiable, Hashable {
            enum RestocksPriceType: String, Codable {
                case regular, consign
            }

            var usSize: String
            let lowestAsk: Double?
            let lowestAskWithSellerFees: Double?
            let lowestAskWithBuyerFees: Double?
            let highestBid: Double?
            let highestBidWithSellerFees: Double?
            let highestBidWithBuyerFees: Double?
            let restocksPriceType: RestocksPriceType?

            let shoeCondition: String?
            let boxCondition: String?

            var id: String { size }
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
        ALLCURRENCIES.first { $0.code == storePrices.first?.currencyCode } ?? Currency(code: .usd, symbol: .usd)
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

    private func price(size: String,
                       storeId: StoreId,
                       feeType: FeeType,
                       currency: Currency,
                       restocksPriceType: StorePrice.StoreInventoryItem.RestocksPriceType?) -> PriceItem {
        let prices = allStorePrices.first(where: { $0.store.id == storeId })?.inventory.filter { $0.size == size }
        let storeInfo = storeInfo.first(where: { $0.store.id == storeId })

        var price = prices?.first
        if let restocksPriceType = restocksPriceType, storeId == .restocks {
            price = prices?.first(where: { $0.restocksPriceType == restocksPriceType })
        }
        var askPrice = price?.lowestAsk
        var bidPrice = price?.highestBid
        if feeType != .None {
            askPrice = feeType == .Buy ? price?.lowestAskWithBuyerFees : price?.lowestAskWithSellerFees
            bidPrice = feeType == .Buy ? price?.highestBidWithBuyerFees : price?.highestBidWithSellerFees
        }
        let priceMissing = PriceItem.PriceInfo(text: "-", num: 0)
        let askInfo: PriceItem.PriceInfo = askPrice.map { price in
            price == 0 ? priceMissing : PriceItem.PriceInfo(text: currency.symbol.rawValue + " \(price.rounded(toPlaces: 0))", num: price)
        } ?? priceMissing
        let bidInfo: PriceItem.PriceInfo = bidPrice.map { price in
            price == 0 ? priceMissing : PriceItem.PriceInfo(text: currency.symbol.rawValue + " \(price.rounded(toPlaces: 0))", num: price)
        } ?? priceMissing

        var sizeQuery = ""
        if let sizeNum = size.number {
            sizeQuery = storeId.rawValue == "goat" || storeId.rawValue == "stockx" ? "size=\(sizeNum)" : ""
        }
        return PriceItem(ask: askInfo, bid: bidInfo, sellLink: storeInfo?.sellUrl, buyLink: (storeInfo?.buyUrl).map { $0 + sizeQuery })
    }

    func priceRow(size: String,
                  priceType: PriceType,
                  feeType: FeeType,
                  stores: [StoreId],
                  restocksPriceType: StorePrice.StoreInventoryItem.RestocksPriceType?) -> PriceRow {
        let prices = stores.compactMap { Store.store(withId: $0) }.map { store -> PriceRow.Price in
            let p = price(size: size, storeId: store.id, feeType: feeType, currency: currency, restocksPriceType: restocksPriceType)
            return PriceRow.Price(primaryText: priceType == .Ask ? p.ask.text : p.bid.text,
                                  secondaryText: priceType == .Ask ? p.bid.text : p.ask.text,
                                  price: priceType == .Ask ? p.ask.num : p.bid.num,
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

    func allPriceRows(priceType: PriceType,
                      feeType: FeeType,
                      stores: [StoreId],
                      restocksPriceType: StorePrice.StoreInventoryItem.RestocksPriceType?) -> [PriceRow] {
        sortedSizes.map { priceRow(size: $0, priceType: priceType, feeType: feeType, stores: stores, restocksPriceType: restocksPriceType) }
    }

    func bestPrice(for size: String, feeType: FeeType, priceType: PriceType, stores: [StoreId]) -> ListingPrice? {
        if let bestPrice = priceRow(size: size, priceType: priceType, feeType: feeType, stores: stores, restocksPriceType: nil).prices.max(by: { $0.price < $1.price }) {
            return ListingPrice(storeId: bestPrice.store.id.rawValue, price: PriceWithCurrency(price: bestPrice.price, currencyCode: currency.code))
        } else {
            return nil
        }
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
                                        productId: "",
                                        gender: .Men)],
             storePrices: [],
             created: 0,
             updated: 0,
             name: "yolo",
             retailPrice: 12,
             imageURL: nil)
}

extension Item {
    func databaseId(settings: CopDeckSettings) -> String {
        Item.databaseId(itemId: id, settings: settings)
    }

    static func idWithoutForwardSlash(itemId: String) -> String {
        itemId.replacingOccurrences(of: "/", with: ".")
    }

    static func databaseId(itemId: String, settings: CopDeckSettings?) -> String {
        let baseId = idWithoutForwardSlash(itemId: itemId)
        if let settings = settings {
            return "\(baseId)-\(settings.feeCalculation.country.region)-\(settings.currency.code.rawValue)"
        } else {
            return baseId
        }
    }

    var isUptodate: Bool {
        guard let updated = updated, !updated.isOlderThan(minutes: World.Constants.itemPricesRefreshPeriodMin) else {
            return false
        }
        return true
    }

    var strippedOfPrices: Item {
        var copy = self
        copy.storeInfo = []
        copy.storePrices = []
        copy.retailPrice = nil
        copy.created = Date.serverDate
        return copy
    }
}

extension Item.StorePrice.StoreInventoryItem {
    enum CodingKeys: String, CodingKey {
        case size
        case lowestAsk
        case lowestAskWithSellerFees
        case lowestAskWithBuyerFees
        case highestBid
        case highestBidWithSellerFees
        case highestBidWithBuyerFees
        case shoeCondition
        case boxCondition
        case restocksPriceType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        usSize = try container.decode(String.self, forKey: .size)
        lowestAsk = try container.decodeIfPresent(Double.self, forKey: .lowestAsk)
        lowestAskWithSellerFees = try container.decodeIfPresent(Double.self, forKey: .lowestAskWithSellerFees)
        lowestAskWithBuyerFees = try container.decodeIfPresent(Double.self, forKey: .lowestAskWithBuyerFees)
        highestBid = try container.decodeIfPresent(Double.self, forKey: .highestBid)
        highestBidWithSellerFees = try container.decodeIfPresent(Double.self, forKey: .highestBidWithSellerFees)
        highestBidWithBuyerFees = try container.decodeIfPresent(Double.self, forKey: .highestBidWithBuyerFees)
        shoeCondition = try container.decodeIfPresent(String.self, forKey: .shoeCondition)
        boxCondition = try container.decodeIfPresent(String.self, forKey: .boxCondition)
        restocksPriceType = try container.decodeIfPresent(RestocksPriceType.self, forKey: .restocksPriceType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(usSize, forKey: .size)
        try container.encode(lowestAsk, forKey: .lowestAsk)
        try container.encode(highestBid, forKey: .highestBid)
        try container.encode(shoeCondition, forKey: .shoeCondition)
        try container.encode(boxCondition, forKey: .boxCondition)
        try container.encode(restocksPriceType, forKey: .restocksPriceType)
    }
}

extension Item.StorePrice.StoreInventoryItem: WithVariableShoeSize {}
