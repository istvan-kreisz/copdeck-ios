//
//  InventoryItem.swift
//  CopDeck
//
//  Created by István Kreisz on 7/21/21.
//

import Foundation

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

    let id: String
    var itemId: String?
    var name: String
    var purchasePrice: PriceWithCurrency?
    let imageURL: ImageURL?
    var usSize: String
    var condition: Condition
    var listingPrices: [ListingPrice] = []
    var copdeckPrice: ListingPrice?
    var soldPrice: SoldPrice?
    var status: SoldStatus? = .None
    var notes: String?
    let pendingImport: Bool?
    let created: Double?
    let updated: Double?
    var purchasedDate: Double?
    var soldDate: Double?

    var purchasedDateComponents: DateComponents? {
        purchasedDate.serverDate.map { Calendar.current.dateComponents([.year, .month], from: $0) }
    }

    var soldDateComponents: DateComponents? {
        soldDate.serverDate.map { Calendar.current.dateComponents([.year, .month], from: $0) }
    }

    enum CodingKeys: String, CodingKey {
        case id, itemId, name, purchasePrice, imageURL, usSize = "size", condition, copdeckPrice, listingPrices, soldPrice, status, notes, pendingImport,
             created, updated, purchasedDate, soldDate
    }
}

extension InventoryItem {
    init(id: String,
         itemId: String?,
         name: String,
         purchasePrice: PriceWithCurrency?,
         imageURL: ImageURL?,
         size: String,
         condition: Condition,
         listingPrices: [ListingPrice] = [],
         copdeckPrice: ListingPrice?,
         soldPrice: SoldPrice?,
         status: SoldStatus? = .None,
         notes: String?,
         pendingImport: Bool?,
         created: Double?,
         updated: Double?,
         purchasedDate: Double?,
         soldDate: Double?) {
        self.init(id: id,
                  itemId: itemId,
                  name: name,
                  purchasePrice: purchasePrice,
                  imageURL: imageURL,
                  usSize: convertSize(from: AppStore.default.state.settings.shoeSize, to: .US, size: size),
                  condition: condition,
                  soldPrice: soldPrice,
                  notes: notes,
                  pendingImport: pendingImport,
                  created: created,
                  updated: updated,
                  purchasedDate: purchasedDate,
                  soldDate: soldDate)
    }

    init(fromItem item: Item, size: String? = nil) {
        self.init(id: UUID().uuidString,
                  itemId: item.id,
                  name: item.name ?? "",
                  purchasePrice: item.retailPrice.asPriceWithCurrency(currency: item.currency),
                  imageURL: item.imageURL,
                  size: (size ?? item.sortedSizes.first) ?? "",
                  condition: .new,
                  copdeckPrice: nil,
                  soldPrice: nil,
                  notes: nil,
                  pendingImport: nil,
                  created: Date.serverDate,
                  updated: Date.serverDate,
                  purchasedDate: Date.serverDate,
                  soldDate: nil)
    }

    func copy(withName name: String, itemId: String?, notes: String?) -> InventoryItem {
        var copy = self
        copy.name = name
        copy.itemId = itemId
        copy.notes = notes
        return copy
    }

    static let empty = InventoryItem(id: "",
                                     itemId: "",
                                     name: "",
                                     purchasePrice: nil,
                                     imageURL: nil,
                                     size: "",
                                     condition: .new,
                                     listingPrices: [],
                                     copdeckPrice: nil,
                                     soldPrice: nil,
                                     status: nil,
                                     notes: nil,
                                     pendingImport: nil,
                                     created: nil,
                                     updated: nil,
                                     purchasedDate: nil,
                                     soldDate: nil)
}

extension InventoryItem: WithVariableShoeSize {}

extension InventoryItem {
    static func purchaseSummary(forMonth month: Int, andYear year: Int, inventoryItems: [InventoryItem]) -> MonthlyStatistics {
        let soldInventoryItems = inventoryItems.filter { $0.soldDateComponents?.year == year && $0.soldDateComponents?.month == month }
        let purchasedInventoryItems = inventoryItems.filter { $0.purchasedDateComponents?.year == year && $0.purchasedDateComponents?.month == month }

        let purchasedPrices = purchasedInventoryItems.compactMap(\.purchasePrice?.price)
        let soldPrices = soldInventoryItems.compactMap(\.soldPrice?.price?.price)
        return MonthlyStatistics(year: year, month: month, purchasPrices: purchasedPrices, soldPrices: soldPrices)
    }

    static func monthlyStatistics(for inventoryItems: [InventoryItem]) -> [MonthlyStatistics] {
        let dates = inventoryItems.compactMap(\.purchasedDate) + inventoryItems.filter { $0.status == .Sold }.compactMap(\.soldDate)

        guard let dateMin = dates.min().map({ Date(timeIntervalSince1970: $0 / 1000) }),
              let dateMax = dates.max().map({ Date(timeIntervalSince1970: $0 / 1000) })
        else { return [] }
        let dateMinComponents = Calendar.current.dateComponents([.year, .month], from: dateMin)
        let dateMaxComponents = Calendar.current.dateComponents([.year, .month], from: dateMax)

        guard let minYear = dateMinComponents.year, let minMonth = dateMinComponents.month,
              let maxYear = dateMaxComponents.year, let maxMonth = dateMaxComponents.month
        else { return [] }
        var monthlySummaries: [MonthlyStatistics] = []

        if minYear == maxYear {
            for month in stride(from: minMonth, to: maxMonth, by: 1) {
                let summary = purchaseSummary(forMonth: month, andYear: minYear, inventoryItems: inventoryItems)
                monthlySummaries.append(summary)
            }
        } else {
            for year in stride(from: minYear, to: maxYear, by: 1) {
                var startMonth: Int = 1
                var endMonth: Int = 12
                if year == minYear {
                    startMonth = minMonth
                } else if year == maxYear {
                    endMonth = maxMonth
                }
                for month in stride(from: startMonth, to: endMonth, by: 1) {
                    let summary = purchaseSummary(forMonth: month, andYear: year, inventoryItems: inventoryItems)
                    monthlySummaries.append(summary)
                }
            }
        }
        return monthlySummaries
    }
}
