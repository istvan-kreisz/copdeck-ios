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

    func inventoryItems(allInventoryItems: [InventoryItem]) -> [InventoryItem] {
        allInventoryItems.filter { inventoryItem in items.contains(where: { inventoryItem.id == $0.inventoryItemId }) }
    }

    static func allStack(inventoryItems: [InventoryItem]) -> Stack {
        .init(id: "all", name: "All", isPublished: false, items: inventoryItems.map { .init(inventoryItemId: $0.id) })
    }
}


struct StackItem: Codable, Equatable {
    let inventoryItemId: String
}
