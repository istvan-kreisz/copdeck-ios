//
//  DefaultDataController.swift
//  CopDeck
//
//  Created by István Kreisz on 7/8/21.
//

import Foundation
import Combine

class DefaultDataController: DataController {
    let backendAPI: API
    let localScraper: API
    let databaseManager: DatabaseManager

    lazy var inventoryItemsPublisher = databaseManager.inventoryItemsPublisher
    lazy var stacksPublisher = databaseManager.stacksPublisher
    lazy var userPublisher = databaseManager.userPublisher
    lazy var exchangeRatesPublisher = databaseManager.exchangeRatesPublisher
    lazy var errorsPublisher = databaseManager.errorsPublisher
    lazy var cookiesPublisher = localScraper.cookiesPublisher
    lazy var imageDownloadHeadersPublisher = localScraper.imageDownloadHeadersPublisher

    init(backendAPI: API, localScraper: API, databaseManager: DatabaseManager) {
        self.backendAPI = backendAPI
        self.localScraper = localScraper
        self.databaseManager = databaseManager
    }

    func getExchangeRates(settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<ExchangeRates, AppError> {
        localScraper.getExchangeRates(settings: settings, exchangeRates: exchangeRates)
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
                ItemCache.default.insert(item: updatedItem, settings: settings)
                if updatedItem.updated != item?.updated {
                    self?.databaseManager.update(item: updatedItem, settings: settings)
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
                            log("cache")
                            return Just(item).setFailureType(to: AppError.self).eraseToAnyPublisher()
                        } else {
                            if fetchMode == .cacheOnly {
                                return self.databaseManager.getItem(withId: itemId, settings: settings).eraseToAnyPublisher()
                                    .map { savedItem -> Item in
                                        if let item = item {
                                            if savedItem.updated ?? 0 > item.updated ?? 0 {
                                                ItemCache.default.insert(item: savedItem, settings: settings)
                                                return savedItem
                                            } else {
                                                return item
                                            }
                                        } else {
                                            ItemCache.default.insert(item: savedItem, settings: settings)
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
                                        if savedItem.isUptodate && !savedItem.storePrices.isEmpty {
                                            ItemCache.default.insert(item: savedItem, settings: settings)
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

    func getCalculatedPrices(for item: Item, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        localScraper.getCalculatedPrices(for: item, settings: settings, exchangeRates: exchangeRates)
    }

    func getUser(withId id: String) -> AnyPublisher<User, AppError> {
        databaseManager.getUser(withId: id)
    }

    func getItem(withId id: String, settings: CopDeckSettings) -> AnyPublisher<Item, AppError> {
        databaseManager.getItem(withId: id, settings: settings)
    }

    func add(exchangeRates: ExchangeRates) {
        databaseManager.add(exchangeRates: exchangeRates)
    }

    func setup(userId: String) {
        databaseManager.setup(userId: userId)
    }

    func delete(stack: Stack) {
        databaseManager.delete(stack: stack)
    }

    func update(stack: Stack) {
        databaseManager.update(stack: stack)
    }

    func add(inventoryItems: [InventoryItem]) {
        databaseManager.add(inventoryItems: inventoryItems)
    }

    func update(item: Item, settings: CopDeckSettings) {
        databaseManager.update(item: item, settings: settings)
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
        databaseManager.update(stack: updatedStack)
    }

    func unstack(inventoryItems: [InventoryItem], stack: Stack) {
        let inventoryItemIds = inventoryItems.map(\.id)
        var updatedStack = stack
        updatedStack.items = updatedStack.items.filter { !inventoryItemIds.contains($0.inventoryItemId) }
        databaseManager.update(stack: updatedStack)
    }

    func updateUser(user: User) {
        databaseManager.updateUser(user: user)
    }

    func stopListening() {
        databaseManager.stopListening()
    }

    func getPopularItems(settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError> {
        localScraper.getPopularItems(settings: settings, exchangeRates: exchangeRates)
    }
}
