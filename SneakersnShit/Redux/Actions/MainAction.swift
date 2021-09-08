//
//  MainAction.swift
//  CopDeck
//
//  Created by István Kreisz on 7/7/21.
//

import UIKit

enum MainAction {
    // auth
    case signOut
    // user - own
    case setUser(user: User)
    case updateUsername(username: String)
    case updateProfileVisibility(isPublic: Bool)
    // feed
    case getFeedPosts(loadMore: Bool)
    case setFeedPosts(feedPosts: PaginatedResult<[FeedPost]>)
    case addFeedPosts(feedPosts: PaginatedResult<[FeedPost]>)
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
    var label: String {
        let mirror = Mirror(reflecting: self)
        if let label = mirror.children.first?.label {
            return label
        } else {
            return String(describing: self)
        }
    }

    var id: String {
        switch self {
        case let .refreshItemIfNeeded(itemId, fetchMode):
            return "refreshItemIfNeeded \(itemId) \(fetchMode.rawValue)"
        default:
            return label
        }
    }
}
