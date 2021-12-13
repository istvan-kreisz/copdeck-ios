//
//  MainAction.swift
//  CopDeck
//
//  Created by István Kreisz on 7/7/21.
//

import UIKit
import Combine

enum MainAction {
    // auth
    case signOut
    // user - own
    case setUser(user: User)
    case updateUsername(username: String)
    case addNewTag(tag: Tag)
    case deleteTag(tag: Tag)
    case enabledNotifications
    // feed
    case getFeedPosts(loadMore: Bool, completion: (Result<PaginatedResult<[FeedPost]>, AppError>) -> Void)
    case toggleLike(stack: Stack, stackOwnerId: String)
    // settings
    case updateSettings(settings: CopDeckSettings)
    // search
    case getSearchResults(searchTerm: String, completion: (Result<[Item], AppError>) -> Void)
    case getPopularItems(completion: (Result<[Item], AppError>) -> Void)
    case searchUsers(searchTerm: String, completion: (Result<[User], AppError>) -> Void)
    case favorite(item: Item)
    case unfavorite(item: Item)
    case addRecentlyViewed(item: Item)
    // users
    case getUserProfile(userId: String, completion: (ProfileData?) -> Void)
    // item details
    case updateItem(item: Item?, itemId: String, styleId: String, forced: Bool, completion: () -> Void)
    case getItemListener(itemId: String, completion: (DocumentListener<Item>) -> Void)
    case getItemImage(itemId: String, completion: (URL?) -> Void)
    case uploadItemImage(itemId: String, image: UIImage)
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
    case runImport(importedUserId: String, completion: (Result<User, Error>) -> Void)
    case finishImport(importedUserId: String, completion: (Result<User, Error>) -> Void)
    case getImportedInventoryItems(importedUserId: String, completion: (Result<[InventoryItem], Error>) -> Void)
    case getAffiliateList(completion: (Result<[ReferralCode], Error>) -> Void)
    // contact
    case sendMessage(email: String, message: String, completion: ((Result<Void, AppError>) -> Void)?)
    // chat
    case getChannels(update: (Result<[Channel], AppError>) -> Void)
    case getChannelListener(channelId: String, cancel: (_ cancel: @escaping () -> Void) -> Void,
                            update: (Result<([Change<Message>], [Message]), AppError>) -> Void)
    case sendChatMessage(message: String, channel: Channel, completion: (Result<Void, AppError>) -> Void)
    case markChannelAsSeen(channel: Channel)
    case getOrCreateChannel(users: [User], completion: (Result<Channel, AppError>) -> Void)
}

extension MainAction: Identifiable, StringRepresentable {
    var id: String {
        switch self {
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
