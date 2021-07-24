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

        appStore.environment.dataController.errorsPublisher
            .sink { appStore.state.error = $0 }
            .store(in: &appStore.effectCancellables)

        appStore.environment.dataController.userPublisher
            .sink { appStore.state.user = $0 }
            .store(in: &appStore.effectCancellables)

        appStore.environment.dataController.inventoryItemsPublisher
            .sink { appStore.state.inventoryItems = $0 }
            .store(in: &appStore.effectCancellables)

        appStore.environment.dataController.exchangeRatesPublisher
            .sink { appStore.state.exchangeRates = $0 }
            .store(in: &appStore.effectCancellables)

        return appStore
    }()
}
