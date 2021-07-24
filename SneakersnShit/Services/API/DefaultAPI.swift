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

    init(backendAPI: API, localScraper: API, databaseManager: DatabaseManager) {
        self.backendAPI = backendAPI
        self.localScraper = localScraper
        self.databaseManager = databaseManager
    }

    func getExchangeRates() -> AnyPublisher<ExchangeRates, AppError> {
        localScraper.getExchangeRates()
    }

    func search(searchTerm: String) -> AnyPublisher<[Item], AppError> {
        localScraper.search(searchTerm: searchTerm)
    }

    func getItemDetails(for item: Item) -> AnyPublisher<Item, AppError> {
        localScraper.getItemDetails(for: item)
    }

    lazy var inventoryItemsPublisher: AnyPublisher<[InventoryItem], Never> = databaseManager.inventoryItemsPublisher

    lazy var userPublisher: AnyPublisher<User, Never> = databaseManager.userPublisher

    lazy var exchangeRatesPublisher: AnyPublisher<ExchangeRates, Never> = databaseManager.exchangeRatesPublisher

    lazy var errorsPublisher: AnyPublisher<AppError, Never> = databaseManager.errorsPublisher

    func setup(userId: String) {
        databaseManager.setup(userId: userId)
    }

    func add(inventoryItems: [InventoryItem]) {
        databaseManager.add(inventoryItems: inventoryItems)
    }

    func update(inventoryItem: InventoryItem) {
        databaseManager.update(inventoryItem: inventoryItem)
    }

    func delete(inventoryItem: InventoryItem) {
        databaseManager.delete(inventoryItem: inventoryItem)
    }

    func updateSettings(settings: CopDeckSettings) {
        databaseManager.updateSettings(settings: settings)
    }

    func stopListening() {
        databaseManager.stopListening()
    }

}
