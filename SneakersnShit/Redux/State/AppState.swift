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
    var editedItem: Item?
    var selectedInventoryItem: InventoryItem?
    var inventoryItems: [InventoryItem] = []
    var inventorySearchResults: [InventoryItem]?
    var error: AppError?
    var exchangeRates: ExchangeRates?
    var cookies: [Cookie] = []

    var settings: CopDeckSettings {
        user?.settings ?? .default
    }

    var currency: Currency {
        settings.currency
    }

    var rates: ExchangeRates {
        exchangeRates ?? .default
    }

    mutating func reset() {
        user = nil
        searchResults = nil
        selectedItem = nil
        editedItem = nil
        selectedInventoryItem = nil
        inventoryItems = []
        inventorySearchResults = nil
        error = nil
        cookies = []
    }
}
