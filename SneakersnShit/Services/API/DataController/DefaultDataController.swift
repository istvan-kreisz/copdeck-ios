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
    let databaseManager: DatabaseManager
    let imageService: ImageService

    lazy var inventoryItemsPublisher = databaseManager.inventoryItemsPublisher.onMain()
    lazy var favoritesPublisher = databaseManager.favoritesPublisher.onMain()
    lazy var recentlyViewedPublisher = databaseManager.recentlyViewedPublisher.onMain()
    lazy var stacksPublisher = databaseManager.stacksPublisher.onMain()
    lazy var userPublisher = databaseManager.userPublisher.onMain()
    lazy var exchangeRatesPublisher = databaseManager.exchangeRatesPublisher.onMain()
    lazy var chatUpdatesPublisher = databaseManager.chatUpdatesPublisher.onMain()
    lazy var errorsPublisher = databaseManager.errorsPublisher.merge(with: backendAPI.errorsPublisher, imageService.errorsPublisher).onMain()
    lazy var canViewPricesPublisher = databaseManager.canViewPricesPublisher.onMain()

    lazy var profileImagePublisher = imageService.profileImagePublisher.onMain()

    private var cancellables: Set<AnyCancellable> = []

    init(backendAPI: BackendAPI, databaseManager: DatabaseManager, imageService: ImageService) {
        self.backendAPI = backendAPI
        self.databaseManager = databaseManager
        self.imageService = imageService
    }

    func reset() {
        backendAPI.reset()
        databaseManager.reset()
        imageService.reset()
    }

    func search(searchTerm: String, settings: CopDeckSettings, exchangeRates: ExchangeRates?) -> AnyPublisher<[Item], AppError> {
        backendAPI.search(searchTerm: searchTerm, settings: settings, exchangeRates: exchangeRates)
    }

    func getPopularItems() -> AnyPublisher<[Item], AppError> {
        databaseManager.getPopularItems()
    }
    
    func getSizeConversions(completion: @escaping ([SizeConversion]) -> Void) {
        databaseManager.getSizeConversions(completion: completion)
    }

    func getItemListener(withId id: String, settings: CopDeckSettings, updated: @escaping (Item) -> Void) -> DocumentListener<Item> {
        databaseManager.getItemListener(withId: id, settings: settings, updated: updated)
    }

    func update(item: Item, forced: Bool, settings: CopDeckSettings, exchangeRates: ExchangeRates?, completion: @escaping () -> Void) {
        backendAPI.update(item: item, forced: forced, settings: settings, exchangeRates: exchangeRates, completion: completion)
    }

    func update(item: Item?, itemId: String, styleId: String, forced: Bool, settings: CopDeckSettings, exchangeRates: ExchangeRates?,
                completion: @escaping () -> Void) {
        let item = item ?? Item(id: itemId, styleId: styleId, storeInfo: [], storePrices: [], name: nil, imageURL: nil)
        update(item: item, forced: forced, settings: settings, exchangeRates: exchangeRates, completion: completion)
    }

    func updateUserItems(completion: @escaping () -> Void) {
        if !AppStore.default.state.globalState.isContentLocked {
            backendAPI.updateUserItems(completion: completion)
        }
    }

    func updateLastPriceViews(itemId: String) {
        databaseManager.updateLastPriceViews(itemId: itemId)
    }

    func getUser(withId id: String) -> AnyPublisher<User, AppError> {
        databaseManager.getUser(withId: id)
    }

    func getItem(withId id: String, settings: CopDeckSettings, completion: @escaping (Result<Item, AppError>) -> Void) {
        databaseManager.getItem(withId: id, settings: settings, completion: completion)
    }

    func getItems(withIds ids: [String], settings: CopDeckSettings, completion: @escaping ([Item]) -> Void) {
        databaseManager.getItems(withIds: ids, settings: settings, completion: completion)
    }

    func getChannels(update: @escaping (Result<[Channel], AppError>) -> Void) {
        databaseManager.getChannels { [weak self] result in
            switch result {
            case let .success(channels):
                self?.updateChannelsWithUsers(channels: channels, update: update)
            case let .failure(error):
                onMain {
                    update(.failure(error))
                }
            }
        }
    }

    private func updateChannelsWithUsers(channels: [Channel], update: @escaping (Result<[Channel], AppError>) -> Void) {
        let allUserIds = channels.flatMap { $0.userIds }.uniqued()
        backendAPI.getUsers(userIds: allUserIds) { [weak self] result in
            switch result {
            case let .failure(error):
                onMain {
                    update(.failure(error))
                }
            case let .success(users):
                self?.getImageURLs(for: users) { updatedUsers in
                    let channelsWithUsers = channels.map { (channel: Channel) -> Channel in
                        var updatedChannel = channel
                        updatedChannel.users = updatedUsers.filter { channel.userIds.contains($0.id) }
                        return updatedChannel
                    }
                    onMain {
                        update(.success(channelsWithUsers))
                    }
                }
            }
        }
    }

    func getChannelListener(channelId: String,
                            cancel: @escaping (_ cancel: @escaping () -> Void) -> Void,
                            update: @escaping (Result<([Change<Message>], [Message]), AppError>) -> Void) {
        databaseManager.getChannelListener(channelId: channelId, cancel: cancel) { result in
            onMain { update(result) }
        }
    }

    func markChannelAsSeen(channel: Channel) {
        databaseManager.markChannelAsSeen(channel: channel)
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
            .onMain()
    }

    func updateLike(onStack stack: Stack, addLike: Bool, stackOwnerId: String) {
        backendAPI.updateLike(onStack: stack, addLike: addLike, stackOwnerId: stackOwnerId)
    }

    func setup(userId: String) {
        databaseManager.setup(userId: userId)
        backendAPI.setup(userId: userId)
        imageService.setup(userId: userId)
    }

    func delete(stack: Stack) {
        databaseManager.delete(stack: stack)
    }

    func update(stacks: [Stack]) {
        databaseManager.update(stacks: stacks)
    }

    func add(inventoryItems: [InventoryItem], completion: @escaping (Result<[InventoryItem], Error>) -> Void) {
        databaseManager.add(inventoryItems: inventoryItems, completion: completion)
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

    func update(user: User) {
        var updatedUser = user
        updatedUser.nameInsensitive = updatedUser.name?.uppercased()
        databaseManager.update(user: updatedUser)
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
            .onMain()
    }

    func searchUsers(searchTerm: String) -> AnyPublisher<[User], AppError> {
        backendAPI.searchUsers(searchTerm: searchTerm)
            .flatMap { [weak self] (users: [User]) -> AnyPublisher<[User], AppError> in
                guard let self = self else { return Just(users).setFailureType(to: AppError.self).eraseToAnyPublisher() }
                return self.getImageURLs(for: users).eraseToAnyPublisher()
            }
            .onMain()
    }

    func getUsers(userIds: [String], completion: @escaping (Result<[User], AppError>) -> Void) {
        backendAPI.getUsers(userIds: userIds) { result in
            onMain { completion(result) }
        }
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

    func sendMessage(user: User, message: String, toChannel channel: Channel, completion: @escaping (Result<Void, AppError>) -> Void) {
        databaseManager.sendMessage(user: user, message: message, toChannel: channel) { result in
            onMain { completion(result) }
        }
    }

    func getOrCreateChannel(users: [User], completion: @escaping (Result<Channel, AppError>) -> Void) {
        databaseManager.getOrCreateChannel(users: users) { result in
            onMain { completion(result) }
        }
    }

    func uploadProfileImage(image: UIImage) {
        imageService.uploadProfileImage(image: image)
    }

    func getImageURLs(for users: [User]) -> AnyPublisher<[User], AppError> {
        imageService.getImageURLs(for: users).onMain()
    }

    func getImageURLs(for users: [User], completion: @escaping ([User]) -> Void) {
        imageService.getImageURLs(for: users, completion: completion)
    }

    func getImage(for itemId: String, completion: @escaping (URL?) -> Void) {
        imageService.getImage(for: itemId) { result in
            onMain { completion(result) }
        }
    }

    func uploadItemImage(itemId: String, image: UIImage) {
        imageService.uploadItemImage(itemId: itemId, image: image)
    }

    func getInventoryItemImages(userId: String, inventoryItem: InventoryItem, completion: @escaping ([URL]) -> Void) {
        imageService.getInventoryItemImages(userId: userId, inventoryItem: inventoryItem) { result in
            onMain { completion(result) }
        }
    }

    func uploadInventoryItemImages(inventoryItem: InventoryItem, images: [UIImage], completion: @escaping ([String]) -> Void) {
        imageService.uploadInventoryItemImages(inventoryItem: inventoryItem, images: images) { result in
            onMain { completion(result) }
        }
    }

    func deleteInventoryItemImage(imageURL: URL, completion: @escaping (Bool) -> Void) {
        imageService.deleteInventoryItemImage(imageURL: imageURL) { result in
            onMain { completion(result) }
        }
    }

    func deleteInventoryItemImages(inventoryItem: InventoryItem) {
        imageService.deleteInventoryItemImages(inventoryItem: inventoryItem)
    }

    func startSpreadsheetImport(urlString: String, completion: @escaping (Error?) -> Void) {
        backendAPI.startSpreadsheetImport(urlString: urlString) { result in
            onMain { completion(result) }
        }
    }

    func revertLastImport(completion: @escaping (Error?) -> Void) {
        backendAPI.revertLastImport { result in
            onMain { completion(result) }
        }
    }

    func getSpreadsheetImportWaitlist(completion: @escaping (Result<[User], Error>) -> Void) {
        databaseManager.getSpreadsheetImportWaitlist { result in
            onMain { completion(result) }
        }
    }

    func updateSpreadsheetImportStatus(importedUserId: String,
                                       spreadSheetImportStatus: User.SpreadSheetImportStatus,
                                       spreadSheetImportError: String?,
                                       completion: @escaping (Result<User, Error>) -> Void) {
        backendAPI.updateSpreadsheetImportStatus(importedUserId: importedUserId,
                                                 spreadSheetImportStatus: spreadSheetImportStatus,
                                                 spreadSheetImportError: spreadSheetImportError) { result in
            onMain { completion(result) }
        }
    }

    func runImport(importedUserId: String, completion: @escaping (Result<User, Error>) -> Void) {
        backendAPI.runImport(importedUserId: importedUserId) { result in
            onMain { completion(result) }
        }
    }

    func finishImport(importedUserId: String, completion: @escaping (Result<User, Error>) -> Void) {
        backendAPI.finishImport(importedUserId: importedUserId) { result in
            onMain { completion(result) }
        }
    }

    func getImportedInventoryItems(importedUserId: String, completion: @escaping (Result<[InventoryItem], Error>) -> Void) {
        backendAPI.getImportedInventoryItems(importedUserId: importedUserId) { result in
            onMain { completion(result) }
        }
    }

    func getAffiliateList(completion: @escaping (Result<[ReferralCode], Error>) -> Void) {
        backendAPI.getAffiliateList { result in
            onMain { completion(result) }
        }
    }

    func refreshUserSubscriptionStatus(completion: ((Result<Void, AppError>) -> Void)?) {
        backendAPI.refreshUserSubscriptionStatus { result in
            onMain { completion?(result) }
        }
    }

    func applyReferralCode(_ code: String, completion: ((Result<Void, AppError>) -> Void)?) {
        backendAPI.applyReferralCode(code) { result in
            onMain { completion?(result) }
        }
    }

    func sendMessage(email: String, message: String, completion: ((Result<Void, AppError>) -> Void)?) {
        backendAPI.sendMessage(email: email, message: message) { result in
            onMain { completion?(result) }
        }
    }

    func getToken(byId id: String, completion: @escaping (NotificationToken?) -> Void) {
        databaseManager.getToken(byId: id) { result in
            onMain { completion(result) }
        }
    }

    func setToken(_ token: NotificationToken, completion: @escaping (Result<[NotificationToken], AppError>) -> Void) {
        databaseManager.setToken(token) { result in
            onMain { completion(result) }
        }
    }

    func deleteToken(_ token: NotificationToken, completion: @escaping (AppError?) -> Void) {
        databaseManager.deleteToken(token) { result in
            onMain { completion(result) }
        }
    }

    func deleteToken(byId id: String, completion: @escaping (AppError?) -> Void) {
        databaseManager.deleteToken(byId: id) { result in
            onMain { completion(result) }
        }
    }
}

extension DefaultDataController {
    static func config(from settings: CopDeckSettings, exchangeRates: ExchangeRates?) -> APIConfig {
        var showLogs = false
        if DebugSettings.shared.isInDebugMode {
            showLogs = DebugSettings.shared.showScraperLogs
        }
        return APIConfig(currency: settings.currency,
                         isLoggingEnabled: showLogs,
                         exchangeRates: exchangeRates,
                         feeCalculation: settings.feeCalculation)
    }
}
