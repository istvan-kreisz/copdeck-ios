//
//  DefaultDataController.swift
//  CopDeck
//
//  Created by István Kreisz on 7/8/21.
//

import Foundation
import Combine

class DefaultDataController: DataController {
    let backendAPI: BackendAPI
    let localScraper: LocalAPI
    let databaseManager: DatabaseManager

    lazy var inventoryItemsPublisher = databaseManager.inventoryItemsPublisher
    lazy var stacksPublisher = databaseManager.stacksPublisher
    lazy var userPublisher = databaseManager.userPublisher
    lazy var exchangeRatesPublisher = databaseManager.exchangeRatesPublisher
    lazy var errorsPublisher = databaseManager.errorsPublisher
    lazy var popularItemsPublisher = databaseManager.popularItemsPublisher
    lazy var cookiesPublisher = localScraper.cookiesPublisher
    lazy var imageDownloadHeadersPublisher = localScraper.imageDownloadHeadersPublisher

    private var cancellables: Set<AnyCancellable> = []

    init(backendAPI: BackendAPI, localScraper: LocalAPI, databaseManager: DatabaseManager) {
        self.backendAPI = backendAPI
        self.localScraper = localScraper
        self.databaseManager = databaseManager
    }

    func reset() {
        backendAPI.reset()
        databaseManager.reset()
        localScraper.reset()
    }

    func search(searchTerm: String, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError> {
        localScraper.search(searchTerm: searchTerm, settings: settings, exchangeRates: exchangeRates)
    }

    private func refreshItem(for item: Item?,
                             itemId: String,
                             settings: CopDeckSettings,
                             exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        log("refreshing item with id: \(itemId)")
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
                            log("cache itemId: \(item.id)")
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
                    log("--> cached item with id: \(item.id)")
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

    func setup(userId: String) {
        databaseManager.setup(userId: userId)
        backendAPI.setup(userId: userId)
    }

    func delete(stack: Stack) {
        backendAPI.delete(stack: stack)
    }

    func update(stack: Stack) {
        backendAPI.update(stack: stack)
    }

    func add(inventoryItems: [InventoryItem]) {
        backendAPI.add(inventoryItems: inventoryItems)
    }

    func update(item: Item, settings: CopDeckSettings) {
        backendAPI.update(item: item, settings: settings)
    }

    func update(inventoryItem: InventoryItem) {
        backendAPI.update(inventoryItem: inventoryItem)
    }

    func delete(inventoryItems: [InventoryItem]) {
        backendAPI.delete(inventoryItems: inventoryItems)
    }

    func stack(inventoryItems: [InventoryItem], stack: Stack) {
        var updatedStack = stack
        updatedStack.items += inventoryItems
            .filter { inventoryItem in
                !updatedStack.items.contains(where: { $0.inventoryItemId == inventoryItem.id })
            }
            .map { .init(inventoryItemId: $0.id) }
        backendAPI.update(stack: updatedStack)
    }

    func unstack(inventoryItems: [InventoryItem], stack: Stack) {
        let inventoryItemIds = inventoryItems.map(\.id)
        var updatedStack = stack
        updatedStack.items = updatedStack.items.filter { !inventoryItemIds.contains($0.inventoryItemId) }
        backendAPI.update(stack: updatedStack)
    }

    func getPopularItems(settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError> {
        localScraper.getPopularItems(settings: settings, exchangeRates: exchangeRates)
    }

    func update(user: User) {
        backendAPI.update(user: user)
    }

    func deleteUser() {
        backendAPI.deleteUser()
    }
}
