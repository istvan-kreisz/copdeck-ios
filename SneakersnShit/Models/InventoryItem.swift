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

    enum CodingKeys: String, CodingKey {
        case id, itemId, name, purchasePrice, imageURL, usSize = "size", condition, copdeckPrice, listingPrices, soldPrice, status, notes, pendingImport,
             created, updated
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
         updated: Double?) {
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
                  updated: updated)
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

extension InventoryItem: WithVariableShoeSize {}
