//
//  DatabaseManager.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/19/21.
//

import Foundation
import Combine

protocol DatabaseManagerDelegate: AnyObject {
    func updatedItems(newItems: [Item])
}

protocol DatabaseManager {
    // init
    func setup(userId: String, delegate: DatabaseManagerDelegate?)

    // write
    func addToInventory(item: Item)
    func deleteFromInventory(item: Item)
    func updateSettings(settings: CopDeckSettings)

    // read
    func listenToChanges(userId: String)
    func stopListening()
}
