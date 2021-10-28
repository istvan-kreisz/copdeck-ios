//
//  AppState.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Purchases

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
    var showPayment2View = false
    var purchaserInfo: Purchases.PurchaserInfo? {
        didSet {
            if !didFetchPurchaserInfo {
                didFetchPurchaserInfo = true
            }
        }
    }

    var allPackages: [DiscountValue: SubscriptionPackages]?
    var didFetchPurchaserInfo = false

    var subscriptionActive: Bool? {
        purchaserInfo?.entitlements[DefaultPaymentService.entitlementsId]?.isActive == true
    }

    var packages: SubscriptionPackages? {
        let discount = user?.membershipInfo?.discount ?? .noDiscount
        return allPackages?[discount]
    }

    var hasSubscribed: Bool {
        subscriptionActive == true || purchaserInfo?.purchaseDate(forEntitlement: DefaultPaymentService.entitlementsId) != nil
    }

    var settings: CopDeckSettings {
        user?.settings ?? .default
    }
}

struct InventoryState: Equatable {
    var inventoryItems: [InventoryItem] = []
    var stacks: [Stack] = []
    var profileImageURL: URL?
}

struct AppState: Equatable {
    var globalState = GlobalState()
    var searchState = SearchState()
    var feedState = FeedState()
    var inventoryState = InventoryState()

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

    var inventoryItems: [InventoryItem] {
        get { inventoryState.inventoryItems }
        set { inventoryState.inventoryItems = newValue }
    }

    var stacks: [Stack] {
        get { inventoryState.stacks }
        set { inventoryState.stacks = newValue }
    }

    var profileImageURL: URL? {
        get { inventoryState.profileImageURL }
        set { inventoryState.profileImageURL = newValue }
    }

    var purchaserInfo: Purchases.PurchaserInfo? {
        get { globalState.purchaserInfo }
        set { globalState.purchaserInfo = newValue }
    }

    var showPayment2View: Bool {
        get { globalState.showPayment2View }
        set { globalState.showPayment2View = newValue }
    }

    var allPackages: [DiscountValue: SubscriptionPackages]? {
        get { globalState.allPackages }
        set { globalState.allPackages = newValue }
    }

    var packages: SubscriptionPackages? {
        globalState.packages
    }

    var didFetchPurchaserInfo: Bool {
        get { globalState.didFetchPurchaserInfo }
        set { globalState.didFetchPurchaserInfo = newValue }
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
        profileImageURL = nil
        error = nil
        showPayment2View = false
        purchaserInfo = nil
        didFetchPurchaserInfo = false
    }
}
