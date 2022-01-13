//
//  AppState.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Purchases

var isContentLocked: Bool {
    AppStore.default.state.isContentLocked
}

class SearchModel: ObservableObject {
    @Published var state = SearchState()
}

struct SearchState: Equatable {
    var searchResults: [ItemSearchResult] = []
    var popularItems: [ItemSearchResult] = []
    var userSearchResults: [User] = []
}

struct FeedState: Equatable {
    var feedPosts: PaginatedResult<[FeedPost]> = .init(data: [], isLastPage: false)
}

struct GlobalState: Equatable {
    var user: User?
    var firstLoadDone = false
    var error: AppError?
    var favoritedItems: [ItemSearchResult] = []
    var recentlyViewedItems: [ItemSearchResult] = []
    var exchangeRates: ExchangeRates?
    var showPaymentView = false
    var allPackages: [DiscountValue: SubscriptionPackages]?
    var chatUpdates: ChatUpdateInfo = .init(updateInfo: [:])
    var canViewPrices: Bool = true
    var remoteConfig: RemoteConfig?
    var loggedInToRevenueCat = false
    
    var isPaywallEnabled: Bool {
        remoteConfig?.paywallEnabled == true
    }

    var subscriptionActive: Bool {
        user?.subscription == .pro
    }
    
    var isContentLocked: Bool {
        !subscriptionActive && isPaywallEnabled == true
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
    
    var inventoryValue: PriceWithCurrency? {
        let sum = inventoryItems.filter { !$0.isSold }.compactMap(\.bestPrice?.price.price).sum()
        return PriceWithCurrency(price: sum, currencyCode: settings.currency.code)
    }

    var user: User? {
        get { globalState.user }
        set { globalState.user = newValue }
    }

    var firstLoadDone: Bool {
        get { globalState.firstLoadDone }
        set { globalState.firstLoadDone = newValue }
    }

    var error: AppError? {
        get { globalState.error }
        set { globalState.error = newValue }
    }

    var exchangeRates: ExchangeRates? {
        get { globalState.exchangeRates }
        set { globalState.exchangeRates = newValue }
    }

    var favoritedItems: [ItemSearchResult] {
        get { globalState.favoritedItems }
        set { globalState.favoritedItems = newValue }
    }
    
    var recentlyViewedItems: [ItemSearchResult] {
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
        favoritedItems = []
        recentlyViewedItems = []
        error = nil
        showPaymentView = false
        globalState.chatUpdates = .init(updateInfo: [:])
        globalState.canViewPrices = true
        globalState.loggedInToRevenueCat = false
        inventoryState = InventoryState()
    }
}
