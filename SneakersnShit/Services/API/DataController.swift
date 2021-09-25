//
//  API.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Combine
import UIKit

enum FetchMode: String {
    case forcedRefresh
    case cacheOnly
    case cacheOrRefresh
}

protocol LocalAPI {
    var cookiesPublisher: AnyPublisher<[Cookie], Never> { get }
    var imageDownloadHeadersPublisher: AnyPublisher<[HeadersWithStoreId], Never> { get }

    func reset()
    func search(searchTerm: String, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError>
    func getItemDetails(for item: Item?, itemId: String, fetchMode: FetchMode, settings: CopDeckSettings, exchangeRates: ExchangeRates)
        -> AnyPublisher<Item, AppError>
    func getCalculatedPrices(for item: Item, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError>
    func getPopularItems(settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError>
}

protocol BackendAPI {
    var errorsPublisher: AnyPublisher<AppError, Never> { get }

    func setup(userId: String)
    func reset()
    // feed
    func getFeedPosts(loadMore: Bool) -> AnyPublisher<PaginatedResult<[FeedPost]>, AppError>
    // search
    func search(searchTerm: String, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError>
    // item
    func update(item: Item, settings: CopDeckSettings)
    // inventory
    func add(inventoryItems: [InventoryItem])
    func delete(inventoryItems: [InventoryItem])
    func update(inventoryItem: InventoryItem)
    func update(stacks: [Stack])
    func delete(stack: Stack)
    // user
    func update(user: User)
    func deleteUser()
    func getUserProfile(userId: String) -> AnyPublisher<ProfileData, AppError>
    func searchUsers(searchTerm: String) -> AnyPublisher<[User], AppError>
}

protocol DatabaseManager {
    // init
    func setup(userId: String)
    // deinit
    func reset()
    // read
    var inventoryItemsPublisher: AnyPublisher<[InventoryItem], Never> { get }
    var favoritesPublisher: AnyPublisher<[Item], Never> { get }
    var recentlyViewedPublisher: AnyPublisher<[Item], Never> { get }
    var popularItemsPublisher: AnyPublisher<[Item], Never> { get }
    var stacksPublisher: AnyPublisher<[Stack], Never> { get }
    var userPublisher: AnyPublisher<User, Never> { get }
    var exchangeRatesPublisher: AnyPublisher<ExchangeRates, Never> { get }
    var errorsPublisher: AnyPublisher<AppError, Never> { get }

    // read
    func getUser(withId id: String) -> AnyPublisher<User, AppError>
    func getItem(withId id: String, settings: CopDeckSettings) -> AnyPublisher<Item, AppError>

    // write
    func add(inventoryItems: [InventoryItem])
    func delete(inventoryItems: [InventoryItem])
    func update(inventoryItem: InventoryItem)
    func update(stacks: [Stack])
    func delete(stack: Stack)
    func update(user: User)
    func add(recentlyViewedItem: Item)
    func favorite(item: Item)
    func unfavorite(item: Item)
}

protocol ImageService {
    var profileImagePublisher: AnyPublisher<URL?, Never> { get }

    func getImageURLs(for users: [User]) -> AnyPublisher<[User], AppError>
    func uploadProfileImage(image: UIImage)
    func setup(userId: String)
    func reset()
    func getImage(for itemId: String, completion: @escaping (URL?) -> Void)
//    func getItemImages(userId: String, inventoryItemId: String, completion: @escaping ([URL]) -> Void)
    func uploadItemImage(itemId: String, image: UIImage)
}


protocol DataController: LocalAPI, BackendAPI, DatabaseManager, ImageService {
    func stack(inventoryItems: [InventoryItem], stack: Stack)
    func unstack(inventoryItems: [InventoryItem], stack: Stack)
}
