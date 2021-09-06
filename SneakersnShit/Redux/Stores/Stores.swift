//
//  Stores.swift
//  CopDeck
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation

typealias AppStore = ReduxStore<AppState, AppAction, World>

extension AppStore {
    static let `default`: AppStore = {
        let appStore = AppStore(state: .init(), reducer: appReducer, environment: World())
        appStore.setup()
        return appStore
    }()

    func setup() {
        setupTimers()
        setupObservers()
    }

    func setupObservers() {
        environment.dataController.errorsPublisher
            .sink { [weak self] error in
                self?.state.error = error
            }
            .store(in: &effectCancellables)

        environment.dataController.userPublisher
            .sink { [weak self] newUser in
                let oldSettings = self?.state.user?.settings
                let newSettings = newUser.settings
                if oldSettings?.feeCalculation != newSettings?.feeCalculation || oldSettings?.currency != newSettings?.currency {
                    ItemCache.default.removeAll()
                    self?.refreshItemPricesIfNeeded(newUser: newUser)
                }
                self?.state.user = newUser
            }
            .store(in: &effectCancellables)

        environment.dataController.inventoryItemsPublisher
            .sink { [weak self] inventoryItems in
                self?.state.inventoryItems = inventoryItems
                self?.updateAllStack(withInventoryItems: inventoryItems)
                if !inventoryItems.isEmpty, self?.state.didFetchItemPrices == false {
                    self?.refreshItemPricesIfNeeded()
                    self?.state.didFetchItemPrices = true
                }
            }
            .store(in: &effectCancellables)

        environment.dataController.stacksPublisher
            .sink { [weak self] stacks in
                self?.state.stacks = (self?.state.allStack.map { (stack: Stack) in [stack] } ?? []) + stacks
            }
            .store(in: &effectCancellables)

        environment.dataController.exchangeRatesPublisher
            .sink { [weak self] exchangeRates in
                self?.state.exchangeRates = exchangeRates
            }
            .store(in: &effectCancellables)

        environment.dataController.cookiesPublisher.removeDuplicates()
            .combineLatest(environment.dataController.imageDownloadHeadersPublisher.removeDuplicates()) { cookies, headers in
                cookies.map { (cookie: Cookie) -> ScraperRequestInfo in
                    ScraperRequestInfo(storeId: cookie.store,
                                       cookie: cookie.cookie,
                                       imageDownloadHeaders: headers.first(where: { $0.storeId == cookie.store })?.headers ?? [:])
                }
            }
            .sink(receiveValue: { [weak self] in
                self?.state.requestInfo = $0
            })
            .store(in: &effectCancellables)

        environment.dataController.recentlyViewedPublisher
            .sink { [weak self] recentlyViewed in
                self?.state.recentlyViewed = recentlyViewed
            }
            .store(in: &effectCancellables)

        environment.dataController.favoritesPublisher
            .sink { [weak self] favorites in
                self?.state.favoritedItems = favorites
            }
            .store(in: &effectCancellables)

        environment.dataController.profileImagePublisher.sink { [weak self] url in
            self?.state.profileImageURL = url
        }
        .store(in: &effectCancellables)
    }

    func updateAllStack(withInventoryItems inventoryItems: [InventoryItem]) {
        if state.stacks.isEmpty {
            state.stacks = [.allStack(inventoryItems: inventoryItems)]
        } else if let allStackIndex = state.allStackIndex {
            state.stacks[allStackIndex].items = inventoryItems.map { (inventoryItem: InventoryItem) in StackItem(inventoryItemId: inventoryItem.id) }
        }
    }

    func setupTimers() {
        Timer.scheduledTimer(withTimeInterval: 60 * World.Constants.pricesRefreshPeriodMin, repeats: true) { [weak self] _ in
            self?.refreshItemPricesIfNeeded()
        }
    }

    func refreshItemPricesIfNeeded(newUser: User? = nil) {
        guard state.user != nil else { return }
        let idsToRefresh = Set(state.inventoryItems.compactMap { $0.itemId }).filter { id in
            if let item = ItemCache.default.value(forKey: Item.databaseId(itemId: id, settings: newUser?.settings ?? state.settings)) {
                return item.storePrices.isEmpty || !item.isUptodate
            } else {
                return true
            }
        }
        var idsWithDelay = idsToRefresh
            .map { (id: String) in (id, Double.random(in: 0.2 ... 0.45)) }

        idsWithDelay = idsWithDelay
            .enumerated()
            .map { (offset: Int, idWithDelay: (String, Double)) in
                (idWithDelay.0, idWithDelay.1 + (idsWithDelay[safe: offset - 1]?.1 ?? 0))
            }
        log("refreshing prices for items with ids: \(idsToRefresh)", logType: .scraping)
        if !state.didFetchItemPrices {
            idsWithDelay
                .forEach { [weak self] (id: String, _) in
                    self?.send(.main(action: .refreshItemIfNeeded(itemId: id, fetchMode: .cacheOnly)))
                }
        }
        idsWithDelay
            .forEach { (id: String, delay: Double) in
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                    self?.send(.main(action: .refreshItemIfNeeded(itemId: id, fetchMode: .cacheOrRefresh)))
                }
            }
    }
}
