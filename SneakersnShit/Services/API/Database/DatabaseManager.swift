//
//  DatabaseManager.swift
//  CopDeck
//
//  Created by István Kreisz on 7/19/21.
//

import Foundation
import Combine

protocol DatabaseManager {
    // init
    func setup(userId: String)
    // deinit
    func stopListening()
    // read
    var inventoryItemsPublisher: AnyPublisher<[InventoryItem], Never> { get }
    var userPublisher: AnyPublisher<User, Never> { get }
    var exchangeRatesPublisher: AnyPublisher<ExchangeRates, Never> { get }
    var errorsPublisher: AnyPublisher<AppError, Never> { get }
    // write
    func add(inventoryItems: [InventoryItem])
    func update(inventoryItem: InventoryItem)
    func delete(inventoryItem: InventoryItem)
    func updateSettings(settings: CopDeckSettings)
}
