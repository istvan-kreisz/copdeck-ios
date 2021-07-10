//
//  MainAction.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation

enum MainAction {
    case setUserId(String)
    case setUser(User)
    // user
    case getUserData(userId: String)
    case changeUsername(newName: String)
    // exchange rates

    // search
    case getSearchResults(searchTerm: String)
    case setSearchResults([Item])
    // item details
    case getItemDetails(item: Item)
    case setItemDetails(item: Item)
    // inventory
//    case addToInventory(inventoryItem: InventoryItem)
//    case removeFromInventory(inventoryItem: InventoryItem)
//    case setInventoryItems(inventoryItems: [InventoryItem])
//    case removeInventoryItems(inventoryItems: [InventoryItem])
//    case getInventoryItems
}

extension MainAction: IdAble {
    var id: String {
        switch self {
        case .setUserId:
            return "setUserId"
        case .setUser:
            return "setUser"
        case .getUserData:
            return "getUserData"
        case .changeUsername:
            return "changeUsername"
        case .getSearchResults:
            return "getSearchResults"
        case .setSearchResults:
            return "setSearchResults"
        case .getItemDetails:
            return "getItemDetails"
        case .setItemDetails:
            return "setItemDetails"
//        case .addToInventory:
//            return "addToInventory"
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
