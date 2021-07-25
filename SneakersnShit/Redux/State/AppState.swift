//
//  AppState.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation

struct AppState: Equatable {
    var user: User?
    var firstLoadDone = false
    var searchResults: [Item]?
    var selectedItem: Item?
    var inventoryItems: [InventoryItem] = []
    var error: AppError?
    var exchangeRates: ExchangeRates?
}
