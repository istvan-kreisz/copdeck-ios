//
//  Item.swift
//  CopDeck
//
//  Created by István Kreisz on 7/6/21.
//

import Foundation

enum StoreId: String, Codable, CaseIterable, Hashable, Equatable {
    case stockx, klekt, goat, restocks
}

enum StoreName: String, Codable, CaseIterable, Hashable {
    case StockX, Klekt, GOAT, Restocks
}

let ALLSTORES: [Store] = zip(StoreId.allCases, StoreName.allCases).map { (id: StoreId, name: StoreName) in Store(id: id, name: name) }

let ALLSTORESWITHOTHER: [GenericStore] = ALLSTORES
    .map { (store: Store) in GenericStore(id: store.id.rawValue, name: store.name.rawValue) } + [GenericStore(id: "other", name: "Other")]

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

struct SizeConversionItem: Codable, Equatable, Hashable {
    let us: String
    let uk: String?
    let usWoman: String?
    let eu: String?

    func getValue(shoeSize: ShoeSize, gender: Gender?) -> String? {
        switch shoeSize {
        case .EU:
            return eu
        case .UK:
            return uk
        case .US:
            if gender == .Women {
                return usWoman
            } else {
                return us
            }
        }
    }
}

struct Item: Equatable, Identifiable, Hashable, ModelWithDate {
    let id: String
    let styleId: String?
    var storeInfo: [StoreInfo]
    var storePrices: [StorePrice]
    var created: Double?
    var updated: Double?
    let name: String?
    var retailPrice: Double?
    let imageURL: ImageURL?
    var brand: Brand?
    var gender: Gender?
    var itemType: ItemType?
    var brandCalculated: Brand? { brand ?? getBrand(storeInfoArray: storeInfo) }
    var genderCalculated: Gender? { gender ?? getGender(storeInfoArray: storeInfo) }

    var sizeConversion: [SizeConversionItem] {
        storePrices.sorted(by: { ($0.sizeConversion?.count ?? 0) < ($1.sizeConversion?.count ?? 0) }).last?.sizeConversion ?? []
    }

    struct StoreInfo: Codable, Equatable, Identifiable, Hashable {
        let name: String
        let sku: String
        let styleId: String?
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
        var itemType: ItemType?
        let nameId: String?

        var id: String { name }
    }

    struct StorePrice: Codable, Equatable, Hashable {
        let retailPrice: Double?
        let store: Store
        var inventory: [StoreInventoryItem]
        let currencyCode: Currency.CurrencyCode?
        let sizeConversion: [SizeConversionItem]?

        struct StoreInventoryItem: Codable, Equatable, Identifiable, Hashable {
            enum RestocksPriceType: String, Codable {
                case regular, consign

                var name: String {
                    self.rawValue.capitalized
                }

                var reversed: RestocksPriceType {
                    self == .regular ? .consign : .regular
                }
            }

            enum GOATPriceType: String, Codable {
                case regular, instant

                var name: String {
                    self.rawValue.capitalized
                }

                var reversed: GOATPriceType {
                    self == .regular ? .instant : .regular
                }
            }

            var size: String
            let lowestAsk: Double?
            var lowestAskWithSellerFees: Double?
            var lowestAskWithBuyerFees: Double?
            let highestBid: Double?
            var highestBidWithSellerFees: Double?
            var highestBidWithBuyerFees: Double?
            let restocksPriceType: RestocksPriceType?
            let goatPriceType: GOATPriceType?

            let shoeCondition: String?
            let boxCondition: String?

            var id: String { size }

            var isBoxDamaged: Bool {
                boxCondition?.contains("damaged") ?? false
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
        ALLCURRENCIES.first { $0.code == storePrices.first?.currencyCode } ?? Currency(code: .usd, symbol: .usd)
    }

    private func storeInfo(for storeId: StoreId) -> StoreInfo? {
        storeInfo.first { $0.store.id == storeId }
    }

    var bestStoreInfo: StoreInfo? {
        StoreId.allCases.compactMap { storeInfo(for: $0) }.first
    }

    var itemTypeDefaulted: ItemType {
        itemType ?? .shoe
    }

    var isShoe: Bool {
        itemTypeDefaulted == .shoe
    }

    private var allStorePrices: [StorePrice] {
        storePrices.filter { !$0.inventory.isEmpty }
    }

    private var sizes: [String] {
        Array(Set(allStorePrices.flatMap { store in store.inventory.map { $0.size } }))
    }

    var sortedSizes: [String] {
        switch itemTypeDefaulted {
        case .apparel:
            let sizes = ApparelSize.allCases.map(\.rawValue)
            return sizes.sorted { a, b in
                if let aIndex = sizes.firstIndex(of: a), let bIndex = sizes.firstIndex(of: b) {
                    return aIndex < bIndex
                } else if let aNum = a.number, let bNum = b.number {
                    return aNum < bNum
                } else {
                    return true
                }
            }
        case .other:
            return sizes
        case .shoe:
            fallthrough
        default:
            return sizes.sorted { a, b in
                if let aNum = a.number, let bNum = b.number {
                    return aNum < bNum
                } else {
                    return true
                }
            }
        }
    }

    func priceRow(size: String,
                  priceType: PriceType,
                  feeType: FeeType,
                  stores: [StoreId],
                  restocksPriceType: StorePrice.StoreInventoryItem.RestocksPriceType?,
                  goatPriceType: StorePrice.StoreInventoryItem.GOATPriceType?,
                  isInDamagedBox: Bool?) -> PriceRow {
        Self.priceRow(size: size,
                      priceType: priceType,
                      feeType: feeType,
                      stores: stores,
                      restocksPriceType: restocksPriceType,
                      goatPriceType: goatPriceType,
                      isInDamagedBox: isInDamagedBox,
                      currency: currency,
                      prices: allStorePrices,
                      storeInfos: storeInfo)
    }

    func allPriceRows(priceType: PriceType,
                      feeType: FeeType,
                      stores: [StoreId],
                      restocksPriceType: StorePrice.StoreInventoryItem.RestocksPriceType?,
                      goatPriceType: StorePrice.StoreInventoryItem.GOATPriceType?,
                      isInDamagedBox: Bool?) -> [PriceRow] {
        Self.allPriceRows(priceType: priceType,
                          feeType: feeType,
                          stores: stores,
                          restocksPriceType: restocksPriceType,
                          goatPriceType: goatPriceType,
                          isInDamagedBox: isInDamagedBox,
                          sortedSizes: sortedSizes,
                          curency: currency,
                          prices: allStorePrices,
                          storeInfos: storeInfo)
    }

    func bestPrice(forSize size: String, feeType: FeeType, priceType: PriceType, stores: [StoreId]) -> ListingPrice? {
        return Self.bestPrice(forSize: size,
                              feeType: feeType,
                              priceType: priceType,
                              stores: stores,
                              currency: currency,
                              prices: allStorePrices,
                              storeInfos: storeInfo)
    }
}

extension Item {
    static let sample =
        Item(id: "GHVDY45",
             styleId: "GHVDY45",
             storeInfo: [Item.StoreInfo(name: "Stockx",
                                        sku: "GHVDY45",
                                        styleId: "GHVDY45",
                                        slug: "",
                                        retailPrice: 234,
                                        brand: "Adidas",
                                        store: Store(id: .stockx, name: .StockX),
                                        imageURL: "",
                                        url: "",
                                        sellUrl: "",
                                        buyUrl: "",
                                        productId: "",
                                        gender: .Men,
                                        nameId: nil)],
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
            return "\(baseId)-\(settings.feeCalculation.country.code)-\(settings.currency.code.rawValue)"
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
        case goatPriceType
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(size, forKey: .size)
        try container.encode(lowestAsk, forKey: .lowestAsk)
        try container.encode(highestBid, forKey: .highestBid)
        try container.encode(shoeCondition, forKey: .shoeCondition)
        try container.encode(boxCondition, forKey: .boxCondition)
        try container.encode(restocksPriceType, forKey: .restocksPriceType)
        try container.encode(goatPriceType, forKey: .goatPriceType)
    }
}

extension Item: Codable {
    static func convertOldIdToNew(oldId: String) -> String {
        oldId
            .split(separator: "/")
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: ".", with: "") ?? oldId
    }

    enum CodingKeys: String, CodingKey {
        case id, styleId, storeInfo, storePrices, created, updated, name, retailPrice, imageURL, brand, gender, itemType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(String.self, forKey: .id)
        let styleId = try container.decodeIfPresent(String.self, forKey: .styleId)

        if styleId == nil {
            self.id = Self.convertOldIdToNew(oldId: id)
        } else {
            self.id = id
        }
        self.styleId = styleId ?? id

        self.storeInfo = try container.decode([StoreInfo].self, forKey: .storeInfo)
        self.storePrices = try container.decode([StorePrice].self, forKey: .storePrices)
        self.created = try container.decodeIfPresent(Double.self, forKey: .created)
        self.updated = try container.decodeIfPresent(Double.self, forKey: .updated)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.retailPrice = try container.decodeIfPresent(Double.self, forKey: .retailPrice)
        self.imageURL = try container.decodeIfPresent(ImageURL.self, forKey: .imageURL)
        self.brand = try container.decodeIfPresent(Brand.self, forKey: .brand)
        self.gender = try container.decodeIfPresent(Gender.self, forKey: .gender)
        self.itemType = try container.decodeIfPresent(ItemType.self, forKey: .itemType)
    }
}

extension Item {
    static func price(size: String,
                      storeId: StoreId,
                      feeType: FeeType,
                      currency: Currency,
                      restocksPriceType: Item.StorePrice.StoreInventoryItem.RestocksPriceType?,
                      goatPriceType: StorePrice.StoreInventoryItem.GOATPriceType?,
                      isInDamagedBox: Bool?,
                      allPrices: [Item.StorePrice],
                      storeInfos: [Item.StoreInfo]) -> Item.PriceItem {
        let prices = allPrices.first(where: { $0.store.id == storeId })?.inventory.filter { $0.size == size }
        let storeInfo = storeInfos.first(where: { $0.store.id == storeId })

        var price = prices?.first
        if storeId == .restocks {
            if let restocksPriceType = restocksPriceType {
                price = prices?.first(where: { $0.restocksPriceType == restocksPriceType })
            } else {
                price = prices?.min(by: { ($0.lowestAsk ?? 0) < ($1.lowestAsk ?? 0) })
            }
        } else if storeId == .goat {
            if let goatPriceType = goatPriceType {
                price = prices?.first(where: { ($0.goatPriceType ?? .regular) == goatPriceType })
            } else {
                price = prices?.min(by: { ($0.lowestAsk ?? 0) < ($1.lowestAsk ?? 0) })
            }
        }
        var askPrice = price?.lowestAsk
        var bidPrice = price?.highestBid
        if feeType != .None {
            askPrice = feeType == .Buy ? price?.lowestAskWithBuyerFees : price?.lowestAskWithSellerFees
            bidPrice = feeType == .Buy ? price?.highestBidWithBuyerFees : price?.highestBidWithSellerFees
        }
        let priceMissing = Item.PriceItem.PriceInfo(text: "-", num: 0)
        let askInfo: Item.PriceItem.PriceInfo = askPrice.map { price in
            price == 0 ? priceMissing : Item.PriceItem.PriceInfo(text: currency.symbol.rawValue + " \(price.rounded(toPlaces: 0))", num: price)
        } ?? priceMissing
        let bidInfo: Item.PriceItem.PriceInfo = bidPrice.map { price in
            price == 0 ? priceMissing : Item.PriceItem.PriceInfo(text: currency.symbol.rawValue + " \(price.rounded(toPlaces: 0))", num: price)
        } ?? priceMissing

        var sizeQuery = ""
        if let sizeNum = size.number {
            sizeQuery = storeId.rawValue == "goat" || storeId.rawValue == "stockx" ? "size=\(sizeNum)" : ""
        }
        return Item.PriceItem(ask: askInfo, bid: bidInfo, sellLink: storeInfo?.sellUrl, buyLink: (storeInfo?.buyUrl).map { $0 + sizeQuery })
    }

    static func priceRow(size: String,
                         priceType: PriceType,
                         feeType: FeeType,
                         stores: [StoreId],
                         restocksPriceType: Item.StorePrice.StoreInventoryItem.RestocksPriceType?,
                         goatPriceType: StorePrice.StoreInventoryItem.GOATPriceType?,
                         isInDamagedBox: Bool?,
                         currency: Currency,
                         prices: [Item.StorePrice],
                         storeInfos: [Item.StoreInfo]) -> Item.PriceRow {
        let prices = stores.compactMap { Store.store(withId: $0) }.map { store -> Item.PriceRow.Price in
            let p = price(size: size,
                          storeId: store.id,
                          feeType: feeType,
                          currency: currency,
                          restocksPriceType: restocksPriceType,
                          goatPriceType: goatPriceType,
                          isInDamagedBox: isInDamagedBox,
                          allPrices: prices,
                          storeInfos: storeInfos)
            return Item.PriceRow.Price(primaryText: priceType == .Ask ? p.ask.text : p.bid.text,
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
        return Item.PriceRow(size: size, lowest: lowest, highest: highest, prices: prices)
    }

    static func allPriceRows(priceType: PriceType,
                             feeType: FeeType,
                             stores: [StoreId],
                             restocksPriceType: Item.StorePrice.StoreInventoryItem.RestocksPriceType?,
                             goatPriceType: StorePrice.StoreInventoryItem.GOATPriceType?,
                             isInDamagedBox: Bool?,
                             sortedSizes: [String],
                             curency: Currency,
                             prices: [Item.StorePrice],
                             storeInfos: [Item.StoreInfo]) -> [Item.PriceRow] {
        sortedSizes.uniqued()
            .map { priceRow(size: $0,
                            priceType: priceType,
                            feeType: feeType,
                            stores: stores,
                            restocksPriceType: restocksPriceType,
                            goatPriceType: goatPriceType,
                            isInDamagedBox: isInDamagedBox,
                            currency: curency,
                            prices: prices,
                            storeInfos: storeInfos) }
    }

    static func bestPrice(forSize size: String,
                          feeType: FeeType,
                          priceType: PriceType,
                          stores: [StoreId],
                          currency: Currency,
                          prices: [Item.StorePrice],
                          storeInfos: [Item.StoreInfo]) -> ListingPrice? {
        if let bestPrice = priceRow(size: size,
                                    priceType: priceType,
                                    feeType: feeType,
                                    stores: stores,
                                    restocksPriceType: nil,
                                    goatPriceType: nil,
                                    isInDamagedBox: nil,
                                    currency: currency,
                                    prices: prices,
                                    storeInfos: storeInfos).prices
            .max(by: { $0.price < $1.price }) {
            return ListingPrice(storeId: bestPrice.store.id.rawValue, price: PriceWithCurrency(price: bestPrice.price, currencyCode: currency.code))
        } else {
            return nil
        }
    }
}

extension Item {
    init(from itemSearchResult: ItemSearchResult) {
        self.init(id: itemSearchResult.id,
                  styleId: itemSearchResult.styleId,
                  storeInfo: [],
                  storePrices: [],
                  name: itemSearchResult.name,
                  imageURL: itemSearchResult.imageURL)
    }
}
