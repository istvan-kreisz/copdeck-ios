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
    case getUserProfile(userId: String, completion: (ProfileData?) -> Void)
    case setSelectedUser(user: ProfileData?, completion: (ProfileData?) -> Void)
    // item details
    case getItemDetails(item: Item?, itemId: String, fetchMode: FetchMode, completion: ((Item?) -> Void))
    case getItemImage(itemId: String, completion: ((URL?) -> Void))
    case uploadItemImage(itemId: String, image: UIImage)
    case refreshItemIfNeeded(itemId: String, fetchMode: FetchMode)
    case setSelectedItem(item: Item?, completion: (Item?) -> Void)
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
    // photos
    case getInventoryItemImages(userId: String, inventoryItem: InventoryItem, completion: ([URL]) -> Void)
    case uploadInventoryItemImages(inventoryItem: InventoryItem, images: [UIImage], completion: ([String]) -> Void)
    case deleteInventoryItemImage(imageURL: URL, completion: (Bool) -> Void)
    case deleteInventoryItemImages(inventoryItem: InventoryItem)
    // spreadsheet import
    case startSpreadsheetImport(urlString: String, completion: (Error?) -> Void)
    case revertLastImport(completion: (Error?) -> Void)
    // admin
    case getSpreadsheetImportWaitlist(completion: (Result<[User], Error>) -> Void)
    case updateSpreadsheetImportStatus(importedUserId: String,
                                       spreadSheetImportStatus: User.SpreadSheetImportStatus,
                                       spreadSheetImportError: String?,
                                       completion: (Result<User, Error>) -> Void)

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
            return "\(label) \(itemId) \(fetchMode.rawValue)"
        case .getItemImage:
            return "\(label) \(UUID().uuidString)"
        case let .uploadItemImage(itemId, _):
            return "\(label) \(itemId)"
        case let .getInventoryItemImages(userId, inventoryItem, _):
            return "\(label) \(userId) \(inventoryItem.id)"
        case let .uploadInventoryItemImages(inventoryItem, _, _):
            return "\(label) \(inventoryItem.id)"
        case let .deleteInventoryItemImage(url, _):
            return "\(label) \(url.absoluteString)"
        case let .deleteInventoryItemImages(inventoryItem):
            return "\(label) \(inventoryItem.id)"
        default:
            return label
        }
    }
}
