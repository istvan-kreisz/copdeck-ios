//
//  AppState.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Purchases

class SearchModel: ObservableObject {
    @Published var state = SearchState()
}

struct SearchState: Equatable {
    var searchResults: [Item] = []
    var popularItems: [Item] = []
    var userSearchResults: [User] = []
}

struct FeedState: Equatable {
    var feedPosts: PaginatedResult<[FeedPost]> = .init(data: [], isLastPage: false)
}

struct GlobalState: Equatable {
    var user: User?
    var firstLoadDone = false
    var didFetchItemPrices = false
    var error: AppError?
    var favoritedItems: [Item] = []
    var recentlyViewedItems: [Item] = []
    var exchangeRates: ExchangeRates?
    var showPaymentView = false
    var allPackages: [DiscountValue: SubscriptionPackages]?
    var chatUpdates: ChatUpdateInfo = .init(updateInfo: [:])
    
    var bestPrices: [String: ListingPrice] = [:]
    var inventoryValue: PriceWithCurrency?

    var subscriptionActive: Bool {
        user?.subscription == .pro
    }
    
    var isContentLocked: Bool {
        !subscriptionActive && DebugSettings.shared.isPaywallEnabled
    }

    var packages: SubscriptionPackages? {
        let discount = user?.membershipInfo?.discount ?? .noDiscount
        return allPackages?[discount]
    }

    var hasSubscribed: Bool {
        subscriptionActive || user?.subscribedDate != nil
    }

    var settings: CopDeckSettings {
        user?.settings ?? .default
    }
    
    var displayedStores: [StoreId] {
        isContentLocked ? ALLSTORES.map(\.id) : settings.displayedStores
    }
}

struct InventoryState: Equatable {
    var inventoryItems: [InventoryItem] = []
    var stacks: [Stack] = []
    var profileImageURL: URL?
}

struct AppState: Equatable {
    var globalState = GlobalState()
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

    var error: AppError? {
        get { globalState.error }
        set { globalState.error = newValue }
    }

    var exchangeRates: ExchangeRates? {
        get { globalState.exchangeRates }
        set { globalState.exchangeRates = newValue }
    }

    var favoritedItems: [Item] {
        get { globalState.favoritedItems }
        set { globalState.favoritedItems = newValue }
    }
    
    var recentlyViewedItems: [Item] {
        get { globalState.recentlyViewedItems }
        set { globalState.recentlyViewedItems = newValue }
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

    var showPaymentView: Bool {
        get { globalState.showPaymentView }
        set { globalState.showPaymentView = newValue }
    }

    var allPackages: [DiscountValue: SubscriptionPackages]? {
        get { globalState.allPackages }
        set { globalState.allPackages = newValue }
    }

    var packages: SubscriptionPackages? {
        globalState.packages
    }
    
    var isContentLocked: Bool {
        globalState.isContentLocked
    }
    
    var displayedStores: [StoreId] {
        globalState.displayedStores
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

    mutating func reset() {
        user = nil
        inventoryItems = []
        stacks = []
        profileImageURL = nil
        error = nil
        showPaymentView = false
    }
}
