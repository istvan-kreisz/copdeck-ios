//
//  Stores.swift
//  CopDeck
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation

typealias AppStore = ReduxStore<AppState, AppAction, World>

extension AppStore {
    static var `default`: AppStore = {
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
            .sink { [weak self] in
                self?.state.error = $0
            }
            .store(in: &effectCancellables)

        environment.dataController.userPublisher
            .sink { [weak self] newUser in
                self?.state.user = newUser
            }
            .store(in: &effectCancellables)

        environment.dataController.inventoryItemsPublisher
            .sink { [weak self] in
                self?.state.inventoryItems = $0
                self?.updateAllStack(withInventoryItems: $0)
            }
            .store(in: &effectCancellables)

        environment.dataController.stacksPublisher
            .sink { [weak self] stacks in
                self?.state.stacks = (self?.state.allStack.map { [$0] } ?? []) + stacks
            }
            .store(in: &effectCancellables)

        environment.dataController.exchangeRatesPublisher
            .sink { [weak self] in
                self?.state.exchangeRates = $0
            }
            .store(in: &effectCancellables)

        environment.dataController.cookiesPublisher.removeDuplicates()
            .combineLatest(environment.dataController.imageDownloadHeadersPublisher.removeDuplicates()) { cookies, headers in
                cookies.map { cookie -> ScraperRequestInfo in
                    ScraperRequestInfo(storeId: cookie.store,
                                       cookie: cookie.cookie,
                                       imageDownloadHeaders: headers.first(where: { $0.storeId == cookie.store })?.headers ?? [:])
                }
            }
            .sink(receiveValue: { [weak self] in
                self?.state.requestInfo = $0
            })
            .store(in: &effectCancellables)
    }

    func updateAllStack(withInventoryItems inventoryItems: [InventoryItem]) {
        if state.stacks.isEmpty {
            state.stacks = [.allStack(inventoryItems: inventoryItems)]
        } else if let allStackIndex = state.allStackIndex {
            state.stacks[allStackIndex].items = inventoryItems.map { .init(inventoryItemId: $0.id) }
        }
    }

    func setupTimers() {
        refreshExchangeRatesIfNeeded()
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.refreshExchangeRatesIfNeeded()
        }
    }

    func refreshExchangeRatesIfNeeded() {
        if let lastUpdated = state.exchangeRates?.updated {
            if lastUpdated.isOlderThan(minutes: 60) {
                send(.main(action: .getExchangeRates))
            }
        } else {
            send(.main(action: .getExchangeRates))
        }
    }
}
