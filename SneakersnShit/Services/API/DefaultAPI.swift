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

    lazy var inventoryItemsPublisher: AnyPublisher<[InventoryItem], Never> = databaseManager.inventoryItemsPublisher
    lazy var userPublisher: AnyPublisher<User, Never> = databaseManager.userPublisher
    lazy var exchangeRatesPublisher: AnyPublisher<ExchangeRates, Never> = databaseManager.exchangeRatesPublisher
    lazy var errorsPublisher: AnyPublisher<AppError, Never> = databaseManager.errorsPublisher

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
            .eraseToAnyPublisher()
    }

    func getItemDetails(for item: Item?,
                        itemId: String,
                        forced: Bool,
                        settings: CopDeckSettings,
                        exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        if forced {
            return refreshItem(for: item, itemId: itemId, forced: forced, settings: settings, exchangeRates: exchangeRates)
        } else {
            return databaseManager.getItem(withId: itemId, settings: settings)
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

    func updateSettings(settings: CopDeckSettings) {
        databaseManager.updateSettings(settings: settings)
    }

    func stopListening() {
        databaseManager.stopListening()
    }
}
