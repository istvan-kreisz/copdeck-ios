//
//  DatabaseManager.swift
//  CopDeck
//
//  Created by István Kreisz on 11/4/21.
//

import Combine
import UIKit

protocol DatabaseManager: ChatManager {
    // init
    func setup(userId: String)
    func getExchangeRates(completion: @escaping (ExchangeRates) -> Void)
    func getSizeConversions(completion: @escaping ([SizeConversion]) -> Void)
    func getRemoteConfig(completion: @escaping (RemoteConfig) -> Void)
    // deinit
    func reset()
    // read
    var inventoryItemsPublisher: AnyPublisher<[InventoryItem], AppError> { get }
    var favoritesPublisher: AnyPublisher<[Item], AppError> { get }
    var recentlyViewedPublisher: AnyPublisher<[Item], AppError> { get }
    var stacksPublisher: AnyPublisher<[Stack], AppError> { get }
    var userPublisher: AnyPublisher<User, AppError> { get }
    var errorsPublisher: AnyPublisher<AppError, Never> { get }
    var canViewPricesPublisher: AnyPublisher<Bool, AppError> { get }

    // read
    func getUser(withId id: String) -> AnyPublisher<User, AppError>
    func getItem(withId id: String, settings: CopDeckSettings, completion: @escaping (Result<Item, AppError>) -> Void)
    func getItems(withIds ids: [String], settings: CopDeckSettings, completion: @escaping ([Item]) -> Void)
    func getItemListener(withId id: String, settings: CopDeckSettings, updated: @escaping (Item) -> Void) -> DocumentListener<Item>
    func getPopularItems() -> AnyPublisher<[ItemSearchResult], AppError>
    
    // write
    func add(inventoryItems: [InventoryItem], completion: @escaping (Result<[InventoryItem], Error>) -> Void)
    func delete(inventoryItems: [InventoryItem])
    func update(inventoryItem: InventoryItem)
    func update(stacks: [Stack])
    func delete(stack: Stack)
    func update(user: User)
    func add(recentlyViewedItem: Item)
    func favorite(item: Item)
    func unfavorite(item: Item)
    func updateLastPriceViews(itemId: String)

    // admin
    func getSpreadsheetImportWaitlist(completion: @escaping (Result<[User], Error>) -> Void)
    // push notifications
    func getToken(byId id: String, completion: @escaping (NotificationToken?) -> Void)
    func setToken(_ token: NotificationToken, completion: @escaping (Result<[NotificationToken], AppError>) -> Void)
    func deleteToken(_ token: NotificationToken, completion: @escaping (AppError?) -> Void)
    func deleteToken(byId id: String, completion: @escaping (AppError?) -> Void)
}

protocol ChatManager {
    var chatUpdatesPublisher: AnyPublisher<ChatUpdateInfo, AppError> { get }
    func getChannels(update: @escaping (Result<[Channel], AppError>) -> Void)
    func getChannelListener(channelId: String, cancel: @escaping (_ cancel: @escaping () -> Void) -> Void, update: @escaping (Result<([Change<Message>], [Message]), AppError>) -> Void)
    func markChannelAsSeen(channel: Channel)
    func sendMessage(user: User, message: String, toChannel channel: Channel, completion: @escaping (Result<Void, AppError>) -> Void)
    func getOrCreateChannel(users: [User], completion: @escaping (Result<Channel, AppError>) -> Void)
}
