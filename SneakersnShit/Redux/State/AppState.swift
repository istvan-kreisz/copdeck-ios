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
    var feedPosts: PaginatedResult<[FeedPost]> = .init(data: [], isLastPage: false)
    var searchResults: [Item] = []
    var popularItems: [Item] = []
    var selectedItem: Item?
    var favoritedItems: [Item] = []
    var recentlyViewed: [Item] = []
    var selectedInventoryItem: InventoryItem?
    var inventoryItems: [InventoryItem] = []
    var stacks: [Stack] = []
    var error: AppError?
    var exchangeRates: ExchangeRates?
    var requestInfo: [ScraperRequestInfo] = []
    var profileImageURL: URL?
    var selectedUserProfile: ProfileData?
    var userSearchResults: [User] = []

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
        allStackIndex.map { (index: Int) in stacks[index] }
    }

    func requestInfo(for storeId: StoreId) -> ScraperRequestInfo? {
        requestInfo.first(where: { $0.storeId == storeId })
    }

    mutating func reset() {
        user = nil
        feedPosts = .init(data: [], isLastPage: false)
        didFetchItemPrices = false
        searchResults = []
        selectedItem = nil
        selectedInventoryItem = nil
        favoritedItems = []
        recentlyViewed = []
        inventoryItems = []
        stacks = []
        error = nil
        requestInfo = []
    }
}
