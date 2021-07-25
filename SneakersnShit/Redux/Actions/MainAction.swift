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
    // exchange rates
    case getExchangeRates
    // search
    case getSearchResults(searchTerm: String)
    case setSearchResults(searchResults: [Item])
    // item details
    case getItemDetails(item: Item)
    // inventory
    case addToInventory(inventoryItems: [InventoryItem])
//    case removeFromInventory(inventoryItem: InventoryItem)
//    case setInventoryItems(inventoryItems: [InventoryItem])
//    case removeInventoryItems(inventoryItems: [InventoryItem])
//    case getInventoryItems
}

extension MainAction: IdAble {
    var id: String {
        switch self {
        case .signOut:
            return "signOut"
        case .setUser:
            return "setUser"
        case .getExchangeRates:
            return "getExchangeRates"
        case .getSearchResults:
            return "getSearchResults"
        case .setSearchResults:
            return "setSearchResults"
        case .getItemDetails:
            return "getItemDetails"
        case .addToInventory:
            return "addToInventory"
//        case .removeFromInventory:
//            return "removeFromInventory"
//        case .setInventoryItems:
//            return "setInventoryItems"
//        case .removeInventoryItems:
//            return "removeInventoryItems"
//        case .getInventoryItems:
//            return "getInventoryItems"
        }
    }
}
