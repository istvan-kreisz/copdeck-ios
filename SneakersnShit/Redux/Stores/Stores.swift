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
            .sink { [weak self] in self?.state.error = $0 }
            .store(in: &effectCancellables)

        environment.dataController.userPublisher
            .sink { [weak self] in self?.state.user = $0 }
            .store(in: &effectCancellables)

        environment.dataController.inventoryItemsPublisher
            .sink { [weak self] in self?.state.inventoryItems = $0 }
            .store(in: &effectCancellables)

        environment.dataController.exchangeRatesPublisher
            .sink { [weak self] in self?.state.exchangeRates = $0 }
            .store(in: &effectCancellables)
    }

    func setupTimers() {
        refreshExchangeRatesIfNeeded()
        refreshItemsIfNeeded()
        #warning("update")
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.refreshExchangeRatesIfNeeded()
            self?.refreshItemsIfNeeded()
        }
    }

    func refreshExchangeRatesIfNeeded() {
        if let lastUpdated = state.exchangeRates?.updated {
            let timeDiff = (Date().timeIntervalSince1970 - lastUpdated / 1000) / 3600
            if timeDiff > 1 {
                send(.main(action: .getExchangeRates))
            }
        } else {
            send(.main(action: .getExchangeRates))
        }
    }

    func refreshItemsIfNeeded() {
        let itemsToUpdate = state.inventoryItems.allItems.filter { item in
            if let updated = item.updated {
                let timeDiff = (Date().timeIntervalSince1970 - updated / 1000) / 60
                return timeDiff >= 10
            } else {
                return false
            }
        }
    }
}
