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
    var didFetchItemPrices = false
    var searchResults: [Item]?
    var popularItems: [Item]?
    var selectedItem: Item?
    var selectedInventoryItem: InventoryItem?
    var inventoryItems: [InventoryItem] = []
    var stacks: [Stack] = []
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

    var allStackIndex: Int? {
        stacks.firstIndex(where: { $0.id == "all" })
    }

    var allStack: Stack? {
        allStackIndex.map { stacks[$0] }
    }

    func requestInfo(for storeId: StoreId) -> ScraperRequestInfo? {
        requestInfo.first(where: { $0.storeId == storeId })
    }

    mutating func reset() {
        user = nil
        didFetchItemPrices = false
        searchResults = nil
        selectedItem = nil
        selectedInventoryItem = nil
        inventoryItems = []
        stacks = []
        error = nil
        requestInfo = []
    }
}
