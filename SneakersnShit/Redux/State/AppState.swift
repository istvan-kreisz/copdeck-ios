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
    var popularItems: [Item]?
    var selectedItem: Item?
    var editedItem: Item?
    var selectedInventoryItem: InventoryItem?
    var inventoryItems: [InventoryItem] = []
    var stacks: [Stack] = []
    var inventorySearchResults: [InventoryItem]?
    var error: AppError?
    var exchangeRates: ExchangeRates?
    var requestInfo: [ScraperRequestInfo] = []

    var settings: CopDeckSettings {
        user?.settings ?? .default
    }

    var currency: Currency {
        settings.currency
    }

    var rates: ExchangeRates {
        exchangeRates ?? .default
    }

    func requestInfo(for storeId: StoreId) -> ScraperRequestInfo? {
        requestInfo.first(where: { $0.storeId == storeId })
    }

    mutating func reset() {
        user = nil
        searchResults = nil
        selectedItem = nil
        editedItem = nil
        selectedInventoryItem = nil
        inventoryItems = []
        stacks = []
        inventorySearchResults = nil
        error = nil
        requestInfo = []
    }
}
