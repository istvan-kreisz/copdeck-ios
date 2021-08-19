//
//  Stack.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/15/21.
//

import Foundation

struct Stack: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    var isPublished: Bool
    var items: [StackItem]
    let created: Double?
    let updated: Double?

    func inventoryItems(allInventoryItems: [InventoryItem]) -> [InventoryItem] {
        allInventoryItems.filter { inventoryItem in items.contains(where: { inventoryItem.id == $0.inventoryItemId }) }
    }

    static func allStack(inventoryItems: [InventoryItem]) -> Stack {
        .init(id: "all",
              name: "All",
              isPublished: false,
              items: inventoryItems.map { .init(inventoryItemId: $0.id) },
              created: Date().timeIntervalSince1970 * 1000,
              updated: Date().timeIntervalSince1970 * 1000)
    }

    static var empty: Stack {
        .init(id: UUID().uuidString,
              name: "",
              isPublished: false,
              items: [],
              created: Date().timeIntervalSince1970 * 1000,
              updated: Date().timeIntervalSince1970 * 1000)
    }
}

struct StackItem: Codable, Equatable {
    let inventoryItemId: String
}
