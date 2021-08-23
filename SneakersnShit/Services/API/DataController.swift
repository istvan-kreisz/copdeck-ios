//
//  API.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Combine

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
    func getItemDetails(for item: Item?, itemId: String, fetchMode: FetchMode, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError>
    func getCalculatedPrices(for item: Item, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError>
    func getPopularItems(settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError>
}

protocol BackendAPI {
    var errorsPublisher: AnyPublisher<AppError, Never> { get }

    func setup(userId: String)
    func reset()
    // search
    func search(searchTerm: String, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError>
    // item
    func update(item: Item, settings: CopDeckSettings)
    // inventory
    func add(inventoryItems: [InventoryItem])
    func delete(inventoryItems: [InventoryItem])
    func update(inventoryItem: InventoryItem)
    func update(stack: Stack)
    func delete(stack: Stack)
    // user
    func update(user: User)
    func deleteUser()
}

protocol DatabaseManager {
    // init
    func setup(userId: String)
    // deinit
    func reset()
    // read
    var inventoryItemsPublisher: AnyPublisher<[InventoryItem], Never> { get }
    var popularItemsPublisher: AnyPublisher<[Item], Never> { get }
    var stacksPublisher: AnyPublisher<[Stack], Never> { get }
    var userPublisher: AnyPublisher<User, Never> { get }
    var exchangeRatesPublisher: AnyPublisher<ExchangeRates, Never> { get }
    var errorsPublisher: AnyPublisher<AppError, Never> { get }

    func getUser(withId id: String) -> AnyPublisher<User, AppError>
    func getItem(withId id: String, settings: CopDeckSettings) -> AnyPublisher<Item, AppError>
}

protocol DataController: LocalAPI, BackendAPI, DatabaseManager {
    func stack(inventoryItems: [InventoryItem], stack: Stack)
    func unstack(inventoryItems: [InventoryItem], stack: Stack)
}
