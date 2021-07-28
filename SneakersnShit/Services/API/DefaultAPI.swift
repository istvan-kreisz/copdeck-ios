//
//  DefaultAPI.swift
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
                             forced: Bool,
                             settings: CopDeckSettings,
                             exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        localScraper
            .getItemDetails(for: item, itemId: itemId, forced: forced, settings: settings, exchangeRates: exchangeRates)
            .handleEvents(receiveOutput: { [weak self] item in
                self?.databaseManager.update(item: item, settings: settings)
            })
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
            .mapError { error in (error as? AppError) ?? AppError(error: error) }
            .eraseToAnyPublisher()
    }

    func getItemDetails(for item: Item?,
                        itemId: String,
                        forced: Bool,
                        settings: CopDeckSettings,
                        exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        let returnValue: AnyPublisher<Item, AppError>
        if forced {
            returnValue = refreshItem(for: item, itemId: itemId, forced: forced, settings: settings, exchangeRates: exchangeRates)
        } else {
            returnValue = databaseManager.getItem(withId: itemId, settings: settings)
                .flatMap { [weak self] item -> AnyPublisher<Item, AppError> in
                    guard let self = self else {
                        return Fail<Item, AppError>(error: AppError.unknown).eraseToAnyPublisher()
                    }
                    if let updated = item.updated {
                        if updated.isOlderThan(minutes: 30) {
                            return self.refreshItem(for: item, itemId: itemId, forced: forced, settings: settings, exchangeRates: exchangeRates)
                        } else {
                            return Just(item).setFailureType(to: AppError.self).eraseToAnyPublisher()
                        }
                    } else {
                        return self.refreshItem(for: item, itemId: itemId, forced: forced, settings: settings, exchangeRates: exchangeRates)
                    }
                }
                .tryCatch { [weak self] error -> AnyPublisher<Item, AppError> in
                    guard let self = self else {
                        return Fail<Item, AppError>(error: AppError.unknown).eraseToAnyPublisher()
                    }
                    return self.refreshItem(for: item, itemId: itemId, forced: forced, settings: settings, exchangeRates: exchangeRates)
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

    func updateUser(user: User) {
        databaseManager.updateUser(user: user)
    }

    func stopListening() {
        databaseManager.stopListening()
    }
}
