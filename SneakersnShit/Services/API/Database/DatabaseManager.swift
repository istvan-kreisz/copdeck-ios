//
//  DatabaseManager.swift
//  CopDeck
//
//  Created by István Kreisz on 7/19/21.
//

import Foundation
import Combine

protocol DatabaseManager {
    var inventoryItemsPublisher: AnyPublisher<[InventoryItem], Never> { get }
    var settingsPublisher: AnyPublisher<CopDeckSettings, Never> { get }
    var errorsPublisher: AnyPublisher<AppError, Never> { get }
    // init
    func setup(userId: String)
    // write
    func update(inventoryItem: InventoryItem)
    func delete(inventoryItem: InventoryItem)
    func updateSettings(settings: CopDeckSettings)
    // read
    func listenToChanges(userId: String)
    func stopListening()
}
