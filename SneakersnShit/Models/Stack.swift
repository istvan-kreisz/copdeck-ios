//
//  Stack.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/15/21.
//

import Foundation

struct Stack: Codable, Equatable, Identifiable, ModelWithDate {
    let id: String
    let name: String
    var isPublished: Bool
    var items: [StackItem]
    let created: Double?
    let updated: Double?
    let publishedDate: Double?

    func inventoryItems(allInventoryItems: [InventoryItem], filters: Filters, searchText: String) -> [InventoryItem] {
        allInventoryItems.filter { inventoryItem in
            if items.contains(where: { inventoryItem.id == $0.inventoryItemId }), inventoryItem.name.lowercased().fuzzyMatch(searchText.lowercased()) {
                switch filters.soldStatus {
                case .All:
                    return true
                case .Sold:
                    return inventoryItem.status == .Sold
                case .Unsold:
                    return inventoryItem.status != .Sold
                }
            } else {
                return false
            }
        }
    }

    static func allStack(inventoryItems: [InventoryItem]) -> Stack {
        .init(id: "all",
              name: "All",
              isPublished: false,
              items: inventoryItems.map { .init(inventoryItemId: $0.id) },
              created: 0,
              updated: 0,
              publishedDate: nil)
    }

    static var empty: Stack {
        .init(id: UUID().uuidString,
              name: "",
              isPublished: false,
              items: [],
              created: Date().timeIntervalSince1970 * 1000,
              updated: Date().timeIntervalSince1970 * 1000,
              publishedDate: nil)
    }
}

struct StackItem: Codable, Equatable {
    let inventoryItemId: String
}
