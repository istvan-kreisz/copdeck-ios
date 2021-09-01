//
//  MainAction.swift
//  CopDeck
//
//  Created by István Kreisz on 7/7/21.
//

import UIKit

enum MainAction {
    case signOut
    case setUser(user: User)
    case updateUsername(username: String)
    // settings
    case updateSettings(settings: CopDeckSettings)
    // search
    case getSearchResults(searchTerm: String)
    case setSearchResults(searchResults: [Item])
    case getPopularItems
    case setPopularItems(items: [Item])
    case searchUsers(searchTerm: String)
    case setUserSearchResults(searchResults: [User])
    case favorite(item: Item)
    case unfavorite(item: Item)
    case addRecentlyViewed(item: Item)
    // users
    case getUserProfile(userId: String)
    case setSelectedUser(user: ProfileData?)
    // item details
    case getItemDetails(item: Item?, itemId: String, fetchMode: FetchMode)
    case refreshItemIfNeeded(itemId: String, fetchMode: FetchMode)
    case setSelectedItem(item: Item?)
    // inventory
    case addStack(stack: Stack)
    case deleteStack(stack: Stack)
    case updateStack(stack: Stack)
    case addToInventory(inventoryItems: [InventoryItem])
    case updateInventoryItem(inventoryItem: InventoryItem)
    case removeFromInventory(inventoryItems: [InventoryItem])
    case stack(inventoryItems: [InventoryItem], stack: Stack)
    case unstack(inventoryItems: [InventoryItem], stack: Stack)
    case uploadProfileImage(image: UIImage)
}

extension MainAction: Identifiable {
    var id: String {
        switch self {
        case .signOut:
            return "signOut"
        case .setUser:
            return "setUser"
        case .updateUsername:
            return "updateUsername"
        case .updateSettings:
            return "updateSettings"
        case .getSearchResults:
            return "getSearchResults"
        case .setSearchResults:
            return "setSearchResults"
        case .getPopularItems:
            return "getPopularItems"
        case .searchUsers:
            return "searchUsers"
        case .setUserSearchResults:
            return "setUserSearchResults"
        case .favorite:
            return "favorite"
        case .unfavorite:
            return "unfavorite"
        case .addRecentlyViewed:
            return "addRecentlyViewed"
        case .getUserProfile:
            return "getUserProfile"
        case .setSelectedUser:
            return "setSelectedUser"
        case .setPopularItems:
            return "setPopularItems"
        case .getItemDetails:
            return "getItemDetails"
        case let .refreshItemIfNeeded(itemId, fetchMode):
            return "refreshItemIfNeeded \(itemId) \(fetchMode.rawValue)"
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
        case .updateInventoryItem:
            return "updateInventoryItem"
        case .removeFromInventory:
            return "removeFromInventory"
        case .stack:
            return "stack"
        case .unstack:
            return "unstack"
        case .uploadProfileImage:
            return "uploadProfileImage"
        }
    }
}
