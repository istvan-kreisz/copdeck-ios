//
//  Stack.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/15/21.
//

import Foundation

struct Stack: Codable, Equatable, Identifiable, ModelWithDate {
    let id: String
    var name: String
    var caption: String?
    var isPublished: Bool?
    var isPublic: Bool?
    var isSharedViaLink: Bool?
    var items: [StackItem]
    let created: Double?
    let updated: Double?
    var publishedDate: Double?
    var likes: [String]?
    
    var isShared: Bool {
        (isPublic ?? false) || (isPublished ?? false)
    }

    var itemIds: [String] {
        items.map(\.inventoryItemId)
    }

    func inventoryItems(allInventoryItems: [InventoryItem], filters: Filters, searchText: String) -> [InventoryItem] {
        allInventoryItems.filter { (inventoryItem: InventoryItem) -> Bool in
            let hasStackItem = items.contains(where: { (stackItem: StackItem) -> Bool in inventoryItem.id == stackItem.inventoryItemId })
            if hasStackItem {
                let matchesSearchString = inventoryItem.name.lowercased().fuzzyMatch(searchText.lowercased())
                if matchesSearchString {
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
            } else {
                return false
            }
        }
    }

    func linkURL(userId: String) -> String {
        "https://www.copdeck.com/shared/\(id)?userid=\(userId)"
    }

    static func allStack(inventoryItems: [InventoryItem]) -> Stack {
        Stack(id: "all",
              name: "All",
              isPublished: false,
              isPublic: nil,
              isSharedViaLink: nil,
              items: inventoryItems.map { .init(inventoryItemId: $0.id) },
              created: 0,
              updated: 0,
              publishedDate: nil,
              likes: nil)
    }

    static var empty: Stack {
        Stack(id: "empty",
              name: "",
              isPublished: false,
              isPublic: nil,
              isSharedViaLink: nil,
              items: [],
              created: Date.serverDate,
              updated: Date.serverDate,
              publishedDate: nil,
              likes: nil)
    }
}

struct StackItem: Codable, Equatable {
    let inventoryItemId: String
}
