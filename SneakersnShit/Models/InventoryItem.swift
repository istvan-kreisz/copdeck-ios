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
    var size: String
    var condition: Condition
    var listingPrices: [ListingPrice] = []
    var copdeckPrice: ListingPrice?
    var soldPrice: SoldPrice?
    var status: SoldStatus? = .None
    var notes: String?
    let pendingImport: Bool?
    let created: Double?
    let updated: Double?

    enum CodingKeys: String, CodingKey {
        case id, itemId, name, purchasePrice, imageURL, size, condition, copdeckPrice, listingPrices, soldPrice, status, notes, pendingImport, created, updated
    }
}

extension InventoryItem {
    init(fromItem item: Item, size: String? = nil) {
        self.init(id: UUID().uuidString,
                  itemId: item.id,
                  name: item.name ?? "",
                  purchasePrice: item.retailPrice.asPriceWithCurrency(currency: item.currency),
                  imageURL: item.imageURL,
                  size: (size ?? item.sortedSizes.first) ?? "",
                  condition: .new,
                  soldPrice: nil,
                  notes: nil,
                  pendingImport: nil,
                  created: Date().timeIntervalSince1970 * 1000,
                  updated: Date().timeIntervalSince1970 * 1000)
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
                                     updated: nil)
}

enum ShoeSize: String, Codable, Equatable {
    case EU, UK, US
}

protocol VariableShoeSize {
    var size: String { get }
}

extension VariableShoeSize {
    func convertSize(from fromSize: ShoeSize, to toSize: ShoeSize, size: String) -> String {
        // htttps://stockx.com/news/mens-sneakers-sizing-chart/
        // eu, uk, us
        let indexes: [ShoeSize: Int] = [.EU: 0, .UK: 1, .US: 2]
        let conversionChart = [[35.5, 3, 3.5],
                               [36, 3.5, 4],
                               [36.5, 4, 4.5],
                               [37.5, 4.5, 5],
                               [38, 5, 5.5],
                               [38.5, 5.5, 6],
                               [39, 6, 6.5],
                               [40, 6, 7],
                               [40.5, 6.5, 7.5],
                               [41, 7, 8],
                               [42, 7.5, 8.5],
                               [42.5, 8, 9],
                               [43, 8.5, 9.5],
                               [44, 9, 10],
                               [44.5, 9.5, 10.5],
                               [45, 10, 11],
                               [45.5, 10.5, 11.5],
                               [46, 11, 12],
                               [47, 11.5, 12.5],
                               [47.5, 12, 13],
                               [48, 12.5, 13.5],
                               [48.5, 13, 14],
                               [49.5, 14, 15],
                               [50.5, 15, 16],
                               [51.5, 16, 17],
                               [52.5, 17, 18]]

        guard let fromIndex = indexes[fromSize], let toIndex = indexes[toSize] else { return "" }

        guard let row = conversionChart.first(where: { row in
            size.number.map { $0 == row[fromIndex] } ?? false
        })
        else { return "" }

        let sizeNum = row[toIndex]
        return "\(toSize.rawValue) \(sizeNum)"
    }
}
