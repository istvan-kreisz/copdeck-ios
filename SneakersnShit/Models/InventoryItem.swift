//
//  InventoryItem.swift
//  CopDeck
//
//  Created by István Kreisz on 7/21/21.
//

import Foundation

enum ItemType: String, Codable, CaseIterable {
    case shoe, apparel, other
}

struct ListingPrice: Codable, Equatable {
    let storeId: String
    var price: PriceWithCurrency
}

struct PriceWithCurrency: Codable, Equatable {
    let price: Double
    let currencyCode: Currency.CurrencyCode

    var currencySymbol: Currency.CurrencySymbol {
        Currency.symbol(for: currencyCode)
    }

    var asString: String {
        "\(currencySymbol.rawValue)\(price.rounded(toPlaces: 0))"
    }

    func convertedPrice(currency: Currency, exchangeRates: ExchangeRates) -> Double {
        Currency.convert(from: currencyCode, to: currency.code, exchangeRates: exchangeRates) * price
    }
}

struct InventoryItem: Codable, Equatable, Identifiable {
    static let maxPhotoCount = 6

    enum Condition: String, Codable, CaseIterable {
        case new, used
    }

    struct SoldPrice: Codable, Equatable {
        let storeId: String?
        var price: PriceWithCurrency?
    }

    enum SoldStatus: String, Equatable, EnumCodable {
        case None, Listed, Sold
    }

    var id: String
    let itemId: String?
    var styleId: String
    let userId: String?
    var name: String
    var purchasePrice: PriceWithCurrency?
    let imageURL: ImageURL?
    var size: String
    var itemType: ItemType
    var condition: Condition
    var copdeckPrice: ListingPrice?
    var soldPrice: SoldPrice?
    var tags: [Tag]
    var notes: String?
    let pendingImport: Bool?
    let created: Double?
    let updated: Double?
    var purchasedDate: Double?
    var soldDate: Double?
    var gender: Gender?
    var brand: Brand?
    var updateTrigger: Int?

    var brandCalculated: Brand? { brand ?? itemFields?.brand }
    var genderCalculated: Gender? { gender ?? itemFields?.gender }
    var count = 1

    var bestPrice: ListingPrice?
    var itemFields: ItemFields? = nil

    var _addToStacks: [Stack] = []

    var isSold: Bool {
        return soldPrice != nil || tags.contains(.sold)
    }

    var isShoe: Bool {
        itemType == .shoe
    }

    var convertedSize: String {
        get { isShoe ? size.asSize(of: self) : size }
        set {
            size = isShoe ?
                convertSize(from: AppStore.default.state.settings.shoeSize,
                            to: .US,
                            size: newValue,
                            sizeConversion: itemFields?.sizeConversion,
                            gender: genderCalculated,
                            brand: brandCalculated) :
                newValue
        }
    }

    var sortedSizes: [ItemType: [String]] {
        var result: [ItemType: [String]] = [:]
        ItemType.allCases.forEach { itemType in
            let sizes: [String]
            if let itemSizes = itemFields?.sortedSizes, itemFields?.itemType == itemType, !itemSizes.isEmpty {
                sizes = itemSizes
            } else {
                switch itemType {
                case .shoe:
                    sizes = ShoeSize.ALLSHOESIZESUS
                case .apparel:
                    sizes = ApparelSize.allCases.map(\.rawValue)
                case .other:
                    sizes = []
                }
            }
            result[itemType] = sizes
        }
        return result
    }

    var purchasedDateComponents: DateComponents? {
        purchasedDate.serverDate.map { Calendar.current.dateComponents([.year, .month], from: $0) }
    }

    var soldDateComponents: DateComponents? {
        soldDate.serverDate.map { Calendar.current.dateComponents([.year, .month], from: $0) }
    }

    enum CodingKeys: String, CodingKey {
        case id, itemId, styleId, userId, name, purchasePrice, imageURL, size, itemType, condition, copdeckPrice, listingPrices, soldPrice, status, tags, notes,
             pendingImport,
             created, updated, purchasedDate, soldDate, gender, brand, updateTrigger
    }
}

extension InventoryItem {
    init(fromItem item: Item, size: String? = nil) {
        self.init(id: UUID().uuidString,
                  itemId: item.id,
                  styleId: item.styleId ?? item.bestStoreInfo?.styleId ?? "",
                  userId: DerivedGlobalStore.default.globalState.user?.id,
                  name: item.name ?? "",
                  purchasePrice: item.retailPrice.asPriceWithCurrency(currency: USD),
                  imageURL: item.imageURL,
                  size: (size ?? item.sortedSizes.first) ?? "",
                  itemType: item.itemTypeDefaulted,
                  condition: .new,
                  copdeckPrice: nil,
                  soldPrice: nil,
                  tags: [],
                  notes: nil,
                  pendingImport: nil,
                  created: Date.serverDate,
                  updated: Date.serverDate,
                  purchasedDate: Date.serverDate,
                  soldDate: nil,
                  gender: item.gender,
                  brand: item.brand)
    }

    func copy(withName name: String, styleId: String?, notes: String?) -> InventoryItem {
        var copy = self
        copy.name = name
        copy.styleId = styleId ?? ""
        copy.notes = notes
        return copy
    }

    static let empty = InventoryItem(id: "",
                                     itemId: "",
                                     styleId: "",
                                     userId: "",
                                     name: "",
                                     purchasePrice: nil,
                                     imageURL: nil,
                                     size: "",
                                     itemType: .shoe,
                                     condition: .new,
                                     copdeckPrice: nil,
                                     soldPrice: nil,
                                     tags: [],
                                     notes: nil,
                                     pendingImport: nil,
                                     created: nil,
                                     updated: nil,
                                     purchasedDate: nil,
                                     soldDate: nil)

    static var new: InventoryItem {
        InventoryItem(id: UUID().uuidString,
                      itemId: "",
                      styleId: "",
                      userId: DerivedGlobalStore.default.globalState.user?.id,
                      name: "",
                      purchasePrice: nil,
                      imageURL: nil,
                      size: "",
                      itemType: .other,
                      condition: .new,
                      copdeckPrice: nil,
                      soldPrice: nil,
                      tags: [],
                      notes: nil,
                      pendingImport: nil,
                      created: Date.serverDate,
                      updated: Date.serverDate,
                      purchasedDate: Date.serverDate,
                      soldDate: nil)
    }
}

extension InventoryItem {
    static func purchaseSummary(forMonth month: Int, andYear year: Int, inventoryItems: [InventoryItem], currency: Currency,
                                exchangeRates: ExchangeRates) -> MonthlyStatistics {
        let soldInventoryItems = inventoryItems.filter { $0.soldDateComponents?.year == year && $0.soldDateComponents?.month == month && $0.isSold }
        let purchasedInventoryItems = inventoryItems.filter { $0.purchasedDateComponents?.year == year && $0.purchasedDateComponents?.month == month }

        let purchasedPrices = purchasedInventoryItems.compactMap { $0.purchasePrice?.convertedPrice(currency: currency, exchangeRates: exchangeRates) }
        let soldPrices = soldInventoryItems.compactMap { $0.soldPrice?.price?.convertedPrice(currency: currency, exchangeRates: exchangeRates) }
        return MonthlyStatistics(year: year, month: month, purchasPrices: purchasedPrices, soldPrices: soldPrices)
    }

    static func monthlyStatistics(for inventoryItems: [InventoryItem], currency: Currency, exchangeRates: ExchangeRates) -> [MonthlyStatistics] {
        let soldDates = inventoryItems.filter { $0.isSold }.compactMap(\.soldDate)
        let purchasedDates = inventoryItems.compactMap(\.purchasedDate)
        let dates = soldDates + purchasedDates

        guard let dateMin = dates.min().map({ Date(timeIntervalSince1970: $0 / 1000) }),
              let dateMax = dates.max().map({ Date(timeIntervalSince1970: $0 / 1000) })
        else { return [] }
        let dateMinComponents = Calendar.current.dateComponents([.year, .month], from: dateMin)
        let dateMaxComponents = Calendar.current.dateComponents([.year, .month], from: dateMax)

        guard let minYear = dateMinComponents.year,
              let minMonth = dateMinComponents.month,
              let maxYear = dateMaxComponents.year,
              let maxMonth = dateMaxComponents.month
        else { return [] }
        var monthlySummaries: [MonthlyStatistics] = []

        if minYear == maxYear {
            for month in stride(from: minMonth, to: maxMonth + 1, by: 1) {
                let summary = purchaseSummary(forMonth: month, andYear: minYear, inventoryItems: inventoryItems, currency: currency,
                                              exchangeRates: exchangeRates)
                monthlySummaries.append(summary)
            }
        } else {
            for year in stride(from: minYear, to: maxYear + 1, by: 1) {
                var startMonth: Int = 1
                var endMonth: Int = 12
                if year == minYear {
                    startMonth = minMonth
                } else if year == maxYear {
                    endMonth = maxMonth
                }
                for month in stride(from: startMonth, to: endMonth + 1, by: 1) {
                    let summary = purchaseSummary(forMonth: month, andYear: year, inventoryItems: inventoryItems, currency: currency,
                                                  exchangeRates: exchangeRates)
                    monthlySummaries.append(summary)
                }
            }
        }
        return monthlySummaries
    }
}

extension InventoryItem {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)

        let styleId = try container.decodeIfPresent(String.self, forKey: .styleId)
        let itemId = try container.decodeIfPresent(String.self, forKey: .itemId)
        if styleId == nil {
            self.itemId = itemId.map { Item.convertOldIdToNew(oldId: $0) }
        } else {
            self.itemId = itemId
        }
        self.styleId = styleId ?? itemId ?? ""

        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        purchasePrice = try container.decodeIfPresent(PriceWithCurrency.self, forKey: .purchasePrice)
        imageURL = try container.decodeIfPresent(ImageURL.self, forKey: .imageURL)
        let size = try container.decode(String.self, forKey: .size)
        self.size = size.replacingOccurrences(of: "US", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        itemType = try container.decodeIfPresent(ItemType.self, forKey: .itemType) ?? .shoe
        condition = try container.decode(Condition.self, forKey: .condition)
        copdeckPrice = try container.decodeIfPresent(ListingPrice.self, forKey: .copdeckPrice)
        soldPrice = try container.decodeIfPresent(SoldPrice.self, forKey: .soldPrice)
        tags = try container.decodeIfPresent([Tag].self, forKey: .tags) ?? []
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        pendingImport = try container.decodeIfPresent(Bool.self, forKey: .pendingImport)
        created = try container.decodeIfPresent(Double.self, forKey: .created)
        updated = try container.decodeIfPresent(Double.self, forKey: .updated)
        purchasedDate = try container.decodeIfPresent(Double.self, forKey: .purchasedDate)
        soldDate = try container.decodeIfPresent(Double.self, forKey: .soldDate)
        gender = try container.decodeIfPresent(Gender.self, forKey: .gender)
        brand = try container.decodeIfPresent(Brand.self, forKey: .brand)
        updateTrigger = try container.decodeIfPresent(Int.self, forKey: .updateTrigger)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(itemId, forKey: .itemId)
        try container.encode(styleId, forKey: .styleId)
        try container.encodeIfPresent(userId ?? AppStore.default.state.user?.id, forKey: .userId)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(purchasePrice, forKey: .purchasePrice)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encode(size, forKey: .size)
        try container.encode(itemType, forKey: .itemType)
        try container.encode(condition, forKey: .condition)
        try container.encodeIfPresent(copdeckPrice, forKey: .copdeckPrice)
        try container.encodeIfPresent(soldPrice, forKey: .soldPrice)
        try container.encode(tags, forKey: .tags)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encodeIfPresent(pendingImport, forKey: .notes)
        try container.encodeIfPresent(created, forKey: .created)
        try container.encodeIfPresent(updated, forKey: .updated)
        try container.encodeIfPresent(purchasedDate, forKey: .purchasedDate)
        try container.encodeIfPresent(soldDate, forKey: .soldDate)
        try container.encodeIfPresent(gender, forKey: .gender)
        try container.encodeIfPresent(brand, forKey: .brand)
        try container.encodeIfPresent(updateTrigger, forKey: .updateTrigger)
    }
}

extension InventoryItem {
    struct ItemFields: Equatable {
        var brand: Brand?
        var gender: Gender?
        var itemType: ItemType?
        var sortedSizes: [String] = []
        var storePrices: [Item.StorePrice] = []
        #warning("move out of item fields")
        var sizeConversion: [SizeConversionItem] = []
    }
}

extension InventoryItem.ItemFields {
    init(from item: Item, size: String) {
        let storePrices = item.storePrices.map { prices -> Item.StorePrice in
            var itemPrices = prices
            itemPrices.inventory = itemPrices.inventory.filter { $0.size == size }
            return itemPrices
        }
        self.init(brand: item.brand,
                  gender: item.gender,
                  itemType: item.itemTypeDefaulted,
                  sortedSizes: item.sortedSizes,
                  storePrices: storePrices,
                  sizeConversion: item.sizeConversion)
    }
}
