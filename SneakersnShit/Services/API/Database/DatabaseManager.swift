//
//  DatabaseManager.swift
//  CopDeck
//
//  Created by István Kreisz on 7/19/21.
//

import Foundation
import Combine

protocol DatabaseManagerDelegate: AnyObject {
    func updatedInventoryItems(newInventoryItems: [InventoryItem])
    func updatedSettings(newSettings: CopDeckSettings)
    func updatedItems(newItems: [Item])
}

protocol DatabaseManager {
    // init
    func setup(userId: String, delegate: DatabaseManagerDelegate?)

    // write
    func update(inventoryItem: InventoryItem)
    func delete(inventoryItem: InventoryItem)
    func updateSettings(settings: CopDeckSettings)

    // read
    func listenToChanges(userId: String)
    func stopListening()
}
