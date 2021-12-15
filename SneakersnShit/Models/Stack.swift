//
//  Stack.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/15/21.
//

import Foundation

struct Stack: Codable, Equatable, Identifiable, ModelWithDate {
    let id: String
    let userId: String?
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
            let hasStackItem = id == "all" || items.contains(where: { (stackItem: StackItem) -> Bool in inventoryItem.id == stackItem.inventoryItemId })
            if hasStackItem {
                let nameMatchesSearchString = inventoryItem.name.lowercased().fuzzyMatch(searchText.lowercased())
                let notesMatchesSearchString = inventoryItem.notes.map { $0.lowercased().fuzzyMatch(searchText.lowercased()) } ?? false
                if nameMatchesSearchString || notesMatchesSearchString {
                    switch filters.soldStatus {
                    case .All:
                        return true
                    case .Sold:
                        return inventoryItem.isSold
                    case .Unsold:
                        return !inventoryItem.isSold
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

    static let allStack: Stack = {
        Stack(id: "all",
              userId: "all",
              name: "All",
              isPublished: false,
              isPublic: nil,
              isSharedViaLink: nil,
              items: [],
              created: 0,
              updated: 0,
              publishedDate: nil,
              likes: nil)
    }()

    static var empty: Stack {
        Stack(id: "empty",
              userId: AppStore.default.state.user?.id,
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
