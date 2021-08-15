//
//  MainAction.swift
//  CopDeck
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation

enum MainAction {
    case signOut
    case setUser(user: User)
    // settings
    case updateSettings(settings: CopDeckSettings)
    // exchange rates
    case getExchangeRates
    // search
    case getSearchResults(searchTerm: String)
    case setSearchResults(searchResults: [Item])
    case getPopularItems
    case setPopularItems(items: [Item])
    // item details
    case getItemDetails(item: Item?, itemId: String, forced: Bool)
    case setSelectedItem(item: Item?)
    // inventory
    case addStack(stack: Stack)
    case deleteStack(stack: Stack)
    case updateStack(stack: Stack)
    case addToInventory(inventoryItems: [InventoryItem])
    case getInventorySearchResults(searchTerm: String, stack: Stack)
    case removeFromInventory(inventoryItems: [InventoryItem])
    case stack(inventoryItems: [InventoryItem], stack: Stack)
    case unstack(inventoryItems: [InventoryItem], stack: Stack)
}

extension MainAction: Identifiable {
    var id: String {
        switch self {
        case .signOut:
            return "signOut"
        case .setUser:
            return "setUser"
        case .updateSettings:
            return "updateSettings"
        case .getExchangeRates:
            return "getExchangeRates"
        case .getSearchResults:
            return "getSearchResults"
        case .setSearchResults:
            return "setSearchResults"
        case .getPopularItems:
            return "getPopularItems"
        case .setPopularItems:
            return "setPopularItems"
        case .getItemDetails:
            return "getItemDetails"
        case .setSelectedItem:
            return "setSelectedItem"
        case .addStack:
            return "addStack"
        case .deleteStack:
            return "deleteStack"
        case .updateStack:
            return "updateStack"
        case .addToInventory:
            return "addToInventory"
        case .getInventorySearchResults:
            return "getInventorySearchResults"
        case .removeFromInventory:
            return "removeFromInventory"
        case .stack:
            return "stack"
        case .unstack:
            return "unstack"
        }
    }
}
