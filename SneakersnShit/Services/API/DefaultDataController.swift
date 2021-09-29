//
//  DefaultDataController.swift
//  CopDeck
//
//  Created by István Kreisz on 7/8/21.
//

import Foundation
import Combine
import UIKit

class DefaultDataController: DataController {
    let backendAPI: BackendAPI
    let localScraper: LocalAPI
    let databaseManager: DatabaseManager
    let imageService: ImageService

    lazy var inventoryItemsPublisher = databaseManager.inventoryItemsPublisher
    lazy var favoritesPublisher = databaseManager.favoritesPublisher
    lazy var recentlyViewedPublisher = databaseManager.recentlyViewedPublisher
    lazy var stacksPublisher = databaseManager.stacksPublisher
    lazy var userPublisher = databaseManager.userPublisher
    lazy var exchangeRatesPublisher = databaseManager.exchangeRatesPublisher
    lazy var errorsPublisher = databaseManager.errorsPublisher.merge(with: backendAPI.errorsPublisher, imageService.errorsPublisher).eraseToAnyPublisher()
    lazy var popularItemsPublisher = databaseManager.popularItemsPublisher
    lazy var cookiesPublisher = localScraper.cookiesPublisher
    lazy var imageDownloadHeadersPublisher = localScraper.imageDownloadHeadersPublisher

    lazy var profileImagePublisher = imageService.profileImagePublisher

    private var cancellables: Set<AnyCancellable> = []

    init(backendAPI: BackendAPI, localScraper: LocalAPI, databaseManager: DatabaseManager, imageService: ImageService) {
        self.backendAPI = backendAPI
        self.localScraper = localScraper
        self.databaseManager = databaseManager
        self.imageService = imageService
    }

    func reset() {
        backendAPI.reset()
        databaseManager.reset()
        localScraper.reset()
        imageService.reset()
    }

    func search(searchTerm: String, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError> {
        localScraper.search(searchTerm: searchTerm, settings: settings, exchangeRates: exchangeRates)
    }

    private func refreshItem(for item: Item?,
                             itemId: String,
                             settings: CopDeckSettings,
                             exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        log("refreshing item with id: \(itemId)", logType: .scraping)
        return localScraper
            .getItemDetails(for: item, itemId: itemId, fetchMode: .cacheOrRefresh, settings: settings, exchangeRates: exchangeRates)
            .map { refreshedItem in
                if let item = item {
                    return refreshedItem.storePrices.isEmpty ? item : refreshedItem
                } else {
                    return refreshedItem
                }
            }
            .tryCatch { error -> AnyPublisher<Item, AppError> in
                guard let item = item else {
                    return Fail<Item, AppError>(error: error).eraseToAnyPublisher()
                }
                return Just(item).setFailureType(to: AppError.self).eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [weak self] updatedItem in
                self?.cache(item: updatedItem, settings: settings, exchangeRates: exchangeRates)
                if updatedItem.updated != item?.updated {
                    self?.backendAPI.update(item: updatedItem, settings: settings)
                }
            })
            .mapError { error in (error as? AppError) ?? AppError(error: error) }
            .eraseToAnyPublisher()
    }

    #warning("ensure saved data is always returned if fetching fails")
    func getItemDetails(for item: Item?,
                        itemId: String,
                        fetchMode: FetchMode,
                        settings: CopDeckSettings,
                        exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        let returnValue: AnyPublisher<Item, AppError>

        if fetchMode == .forcedRefresh {
            returnValue = refreshItem(for: item, itemId: itemId, settings: settings, exchangeRates: exchangeRates)
        } else {
            returnValue =
                ItemCache.default.valuePublisher(itemId: itemId, settings: settings)
                    .flatMap { [weak self] item -> AnyPublisher<Item, AppError> in
                        guard let self = self else {
                            return Fail<Item, AppError>(error: AppError.unknown).eraseToAnyPublisher()
                        }
                        if let item = item, item.isUptodate, !item.storePrices.isEmpty {
                            log("cache itemId: \(item.id)", logType: .database)
                            return Just(item).setFailureType(to: AppError.self).eraseToAnyPublisher()
                        } else {
                            if fetchMode == .cacheOnly {
                                return self.databaseManager.getItem(withId: itemId, settings: settings).eraseToAnyPublisher()
                                    .map { savedItem -> Item in
                                        if let item = item {
                                            if savedItem.updated ?? 0 > item.updated ?? 0 {
                                                self.cache(item: savedItem, settings: settings, exchangeRates: exchangeRates)
                                                return savedItem
                                            } else {
                                                return item
                                            }
                                        } else {
                                            self.cache(item: savedItem, settings: settings, exchangeRates: exchangeRates)
                                            return savedItem
                                        }
                                    }
                                    .tryCatch { error -> AnyPublisher<Item, AppError> in
                                        if let item = item {
                                            return Just(item).setFailureType(to: AppError.self).eraseToAnyPublisher()
                                        } else {
                                            return Fail<Item, AppError>(error: error).eraseToAnyPublisher()
                                        }
                                    }
                                    .mapError { error in (error as? AppError) ?? AppError(error: error) }
                                    .eraseToAnyPublisher()
                            } else {
                                return self.databaseManager.getItem(withId: itemId, settings: settings).eraseToAnyPublisher()
                                    .flatMap { [weak self] savedItem -> AnyPublisher<Item, AppError> in
                                        guard let self = self else {
                                            return Fail<Item, AppError>(error: AppError.unknown).eraseToAnyPublisher()
                                        }
                                        if savedItem.isUptodate, !savedItem.storePrices.isEmpty {
                                            self.cache(item: savedItem, settings: settings, exchangeRates: exchangeRates)
                                            return Just(savedItem).setFailureType(to: AppError.self).eraseToAnyPublisher()
                                        } else {
                                            return self.refreshItem(for: savedItem, itemId: itemId, settings: settings, exchangeRates: exchangeRates)
                                        }
                                    }
                                    .eraseToAnyPublisher()
                            }
                        }
                    }
                    .tryCatch { [weak self] error -> AnyPublisher<Item, AppError> in
                        guard let self = self else {
                            return Fail<Item, AppError>(error: AppError.unknown).eraseToAnyPublisher()
                        }
                        return self.refreshItem(for: item, itemId: itemId, settings: settings, exchangeRates: exchangeRates)
                    }
                    .mapError { error in (error as? AppError) ?? AppError(error: error) }
                    .eraseToAnyPublisher()
        }
        return returnValue
            .flatMap { [weak self] item -> AnyPublisher<Item, AppError> in
                guard let self = self else {
                    return Fail<Item, AppError>(error: AppError.unknown).eraseToAnyPublisher()
                }
                return self.localScraper.getCalculatedPrices(for: item, settings: settings, exchangeRates: exchangeRates)
            }
            .eraseToAnyPublisher()
    }

    private func cache(item: Item, settings: CopDeckSettings, exchangeRates: ExchangeRates) {
        localScraper.getCalculatedPrices(for: item, settings: settings, exchangeRates: exchangeRates)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { item in
                      log("--> cached item with id: \(item.id)", logType: .database)
                      ItemCache.default.insert(item: item, settings: settings)
                  })
            .store(in: &cancellables)
    }

    func getCalculatedPrices(for item: Item, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        localScraper.getCalculatedPrices(for: item, settings: settings, exchangeRates: exchangeRates)
    }

    func getUser(withId id: String) -> AnyPublisher<User, AppError> {
        databaseManager.getUser(withId: id)
    }

    func getItem(withId id: String, settings: CopDeckSettings) -> AnyPublisher<Item, AppError> {
        databaseManager.getItem(withId: id, settings: settings)
    }

    func getFeedPosts(loadMore: Bool) -> AnyPublisher<PaginatedResult<[FeedPost]>, AppError> {
        backendAPI.getFeedPosts(loadMore: loadMore)
            .flatMap { [weak self] result -> AnyPublisher<PaginatedResult<[FeedPost]>, AppError> in
                guard let self = self else { return Just(result).setFailureType(to: AppError.self).eraseToAnyPublisher() }

                let allUsers: [User] = result.data.compactMap { $0.user }.uniqueById()
                let updatedPosts = self.getImageURLs(for: allUsers).map { (users: [User]) -> [FeedPost] in
                    result.data.map { (post: FeedPost) -> FeedPost in
                        if let updatedUser = users.first(where: { $0.id == post.userId }) {
                            var updatedPost = post
                            updatedPost.user = updatedUser
                            return updatedPost
                        } else {
                            return post
                        }
                    }
                }
                return updatedPosts
                    .map { (feedPosts: [FeedPost]) -> PaginatedResult<[FeedPost]> in
                        PaginatedResult<[FeedPost]>(data: feedPosts, isLastPage: result.isLastPage)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func setup(userId: String) {
        databaseManager.setup(userId: userId)
        backendAPI.setup(userId: userId)
        imageService.setup(userId: userId)
    }

    func update(item: Item, settings: CopDeckSettings) {
        backendAPI.update(item: item, settings: settings)
    }

    func delete(stack: Stack) {
        databaseManager.delete(stack: stack)
    }

    func update(stacks: [Stack]) {
        databaseManager.update(stacks: stacks)
    }

    func add(inventoryItems: [InventoryItem]) {
        databaseManager.add(inventoryItems: inventoryItems)
    }

    func update(inventoryItem: InventoryItem) {
        databaseManager.update(inventoryItem: inventoryItem)
    }

    func delete(inventoryItems: [InventoryItem]) {
        databaseManager.delete(inventoryItems: inventoryItems)
    }

    func stack(inventoryItems: [InventoryItem], stack: Stack) {
        var updatedStack = stack
        updatedStack.items += inventoryItems
            .filter { inventoryItem in
                !updatedStack.items.contains(where: { $0.inventoryItemId == inventoryItem.id })
            }
            .map { .init(inventoryItemId: $0.id) }
        databaseManager.update(stacks: [updatedStack])
    }

    func unstack(inventoryItems: [InventoryItem], stack: Stack) {
        let inventoryItemIds = inventoryItems.map(\.id)
        var updatedStack = stack
        updatedStack.items = updatedStack.items.filter { !inventoryItemIds.contains($0.inventoryItemId) }
        databaseManager.update(stacks: [updatedStack])
    }

    func getPopularItems(settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError> {
        localScraper.getPopularItems(settings: settings, exchangeRates: exchangeRates)
    }

    func update(user: User) {
        var updatedUser = user
        updatedUser.nameInsensitive = updatedUser.name?.capitalized
        databaseManager.update(user: updatedUser)
    }

    func deleteUser() {
        backendAPI.deleteUser()
    }

    func getUserProfile(userId: String) -> AnyPublisher<ProfileData, AppError> {
        backendAPI.getUserProfile(userId: userId)
            .flatMap { [weak self] profileData -> AnyPublisher<ProfileData, AppError> in
                guard let self = self else { return Just(profileData).setFailureType(to: AppError.self).eraseToAnyPublisher() }
                return self.getImageURLs(for: [profileData.user])
                    .combineLatest(Just(profileData).setFailureType(to: AppError.self)) { users, profileData in
                        if let imageURL = users.first?.imageURL, users.first?.id == profileData.user.id {
                            var updatedProfile = profileData
                            updatedProfile.user.imageURL = imageURL
                            return updatedProfile
                        } else {
                            return profileData
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func searchUsers(searchTerm: String) -> AnyPublisher<[User], AppError> {
        backendAPI.searchUsers(searchTerm: searchTerm)
            .flatMap { [weak self] (users: [User]) -> AnyPublisher<[User], AppError> in
                guard let self = self else { return Just(users).setFailureType(to: AppError.self).eraseToAnyPublisher() }
                return self.getImageURLs(for: users).eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }

    func add(recentlyViewedItem: Item) {
        databaseManager.add(recentlyViewedItem: recentlyViewedItem)
    }

    func favorite(item: Item) {
        databaseManager.favorite(item: item)
    }

    func unfavorite(item: Item) {
        databaseManager.unfavorite(item: item)
    }

    func uploadProfileImage(image: UIImage) {
        imageService.uploadProfileImage(image: image)
    }

    func getImageURLs(for users: [User]) -> AnyPublisher<[User], AppError> {
        imageService.getImageURLs(for: users)
    }

    func getImage(for itemId: String, completion: @escaping (URL?) -> Void) {
        imageService.getImage(for: itemId, completion: completion)
    }

    func uploadItemImage(itemId: String, image: UIImage) {
        imageService.uploadItemImage(itemId: itemId, image: image)
    }

    func getInventoryItemImages(userId: String, inventoryItem: InventoryItem, completion: @escaping ([URL]) -> Void) {
        imageService.getInventoryItemImages(userId: userId, inventoryItem: inventoryItem, completion: completion)
    }

    func uploadInventoryItemImages(inventoryItem: InventoryItem, images: [UIImage], completion: @escaping ([String]) -> Void) {
        imageService.uploadInventoryItemImages(inventoryItem: inventoryItem, images: images, completion: completion)
    }

    func deleteInventoryItemImage(imageURL: URL, completion: @escaping (Bool) -> Void) {
        imageService.deleteInventoryItemImage(imageURL: imageURL, completion: completion)
    }

    func deleteInventoryItemImages(inventoryItem: InventoryItem) {
        imageService.deleteInventoryItemImages(inventoryItem: inventoryItem)
    }
    
    func startSpreadsheetImport(urlString: String, completion: @escaping (Error?) -> Void) {
        backendAPI.startSpreadsheetImport(urlString: urlString, completion: completion)
    }
    
    func revertLastImport(completion: @escaping (Error?) -> Void) {
        backendAPI.revertLastImport(completion: completion)
    }
    
    func getSpreadsheetImportWaitlist(completion: @escaping (Result<[User], Error>) -> Void) {
        databaseManager.getSpreadsheetImportWaitlist(completion: completion)
    }

    func updateSpreadsheetImportStatus(importedUserId: String,
                                       spreadSheetImportStatus: User.SpreadSheetImportStatus,
                                       spreadSheetImportError: String?,
                                       completion: @escaping (Result<User, Error>) -> Void) {
        backendAPI.updateSpreadsheetImportStatus(importedUserId: importedUserId,
                                                 spreadSheetImportStatus: spreadSheetImportStatus,
                                                 spreadSheetImportError: spreadSheetImportError,
                                                 completion: completion)
    }
    
    func runImport(importedUserId: String, completion: @escaping (Result<User, Error>) -> Void) {
        backendAPI.runImport(importedUserId: importedUserId, completion: completion)
    }
    
    func getAffiliateList(completion: @escaping (Result<[User], Error>) -> Void) {
        databaseManager.getAffiliateList(completion: completion)
    }
    
    func applyPromoCode(_ code: String, completion: @escaping (Result<Void, Error>) -> Void) {
        backendAPI.applyPromoCode(code, completion: completion)
    }
}
