//
//  AppState.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation

struct SearchState: Equatable {
    var searchResults: [Item] = []
    var popularItems: [Item] = []
    var favoritedItems: [Item] = []
    var recentlyViewed: [Item] = []
    var userSearchResults: [User] = []
}

struct FeedState: Equatable {
    var feedPosts: PaginatedResult<[FeedPost]> = .init(data: [], isLastPage: false)
}

struct GlobalState: Equatable {
    var user: User?
    var firstLoadDone = false
    var didFetchItemPrices = false
    var requestInfo: [ScraperRequestInfo] = []
    var error: AppError?
    var exchangeRates: ExchangeRates?

    var settings: CopDeckSettings {
        user?.settings ?? .default
    }
}

struct AppState: Equatable {
    var inventoryItems: [InventoryItem] = []
    var stacks: [Stack] = []
    var profileImageURL: URL?

    var globalState = GlobalState()
    var searchState = SearchState()
    var feedState = FeedState()

    var user: User? {
        get { globalState.user }
        set { globalState.user = newValue }
    }
    var firstLoadDone: Bool {
        get { globalState.firstLoadDone }
        set { globalState.firstLoadDone = newValue }
    }
    var didFetchItemPrices: Bool {
        get { globalState.didFetchItemPrices }
        set { globalState.didFetchItemPrices = newValue }
    }
    var requestInfo: [ScraperRequestInfo] {
        get { globalState.requestInfo }
        set { globalState.requestInfo = newValue }
    }
    var error: AppError? {
        get { globalState.error }
        set { globalState.error = newValue }
    }
    var exchangeRates: ExchangeRates? {
        get { globalState.exchangeRates }
        set { globalState.exchangeRates = newValue }
    }

    var searchResults: [Item] {
        get { searchState.searchResults }
        set { searchState.searchResults = newValue }
    }
    var popularItems: [Item] {
        get { searchState.popularItems }
        set { searchState.popularItems = newValue }
    }
    var favoritedItems: [Item] {
        get { searchState.favoritedItems }
        set { searchState.favoritedItems = newValue }
    }
    var recentlyViewed: [Item] {
        get { searchState.recentlyViewed }
        set { searchState.recentlyViewed = newValue }
    }
    var userSearchResults: [User] {
        get { searchState.userSearchResults }
        set { searchState.userSearchResults = newValue }
    }
    var feedPosts: PaginatedResult<[FeedPost]> {
        get { feedState.feedPosts }
        set { feedState.feedPosts = newValue }
    }

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
        searchState = SearchState()
        feedState = FeedState()
        user = nil
        didFetchItemPrices = false
        inventoryItems = []
        stacks = []
        error = nil
    }
}
