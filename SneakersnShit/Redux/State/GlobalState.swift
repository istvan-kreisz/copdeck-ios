//
//  GlobalState.swift
//  CopDeck
//
//  Created by István Kreisz on 2/13/23.
//

import Foundation

struct GlobalState: Equatable {
    var user: User?
    var firstLoadDone = false
    var error: AppError?
    var favoritedItems: [ItemSearchResult] = []
    var recentlyViewedItems: [ItemSearchResult] = []
    var exchangeRates: ExchangeRates?
    var showPaymentView = false
    var packages: SubscriptionPackages?
    var chatUpdates: ChatUpdateInfo = .init(updateInfo: [:])
    var canViewPrices: Bool = true
    var remoteConfig: RemoteConfig?
    var loggedInToRevenueCat = false
    var forceShowRefreshInventoryPricesButton = false
    
    var isPaywallEnabled: Bool {
        remoteConfig?.paywallEnabled == true
    }

    var subscriptionActive: Bool {
        user?.subscription == .pro
    }
    
    var isContentLocked: Bool {
        !subscriptionActive && isPaywallEnabled == true
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
