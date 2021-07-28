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
            }
            .store(in: &effectCancellables)

        environment.dataController.exchangeRatesPublisher
            .sink { [weak self] in
                self?.state.exchangeRates = $0
            }
            .store(in: &effectCancellables)

        environment.dataController.cookiesPublisher
            .removeDuplicates()
            .sink(receiveValue: { [weak self] in
                self?.state.cookies = $0
            })
            .store(in: &effectCancellables)
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

    func randomDelay(min: Double = 0.0, max: Double = 0.5) -> Double {
        Double.random(in: min ..< max)
    }
}
