//
//  AppReducer.swift
//  CopDeck
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation
import Combine

#warning("make sure updated & created works correctly")

func appReducer(state: inout AppState,
                action: AppAction,
                environment: World,
                completed: ((Result<Void, AppError>) -> Void)?) -> AnyPublisher<AppAction, Never> {
    switch action {
    case .none:
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .main(action: action):
        switch action {
        case .signOut:
            state.user = nil
            if !state.firstLoadDone {
                state.firstLoadDone = true
            }
            environment.dataController.stopListening()
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        case let .setUser(user):
            if !state.firstLoadDone {
                state.firstLoadDone = true
            }
            state.user = user
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        case let .getSearchResults(searchTerm: searchTerm):
            if searchTerm.isEmpty {
                state.searchResults = []
                return Empty(completeImmediately: true).eraseToAnyPublisher()
            } else {
                return environment.dataController.search(searchTerm: searchTerm, settings: state.settings, exchangeRates: state.rates)
                    .map { AppAction.main(action: .setSearchResults(searchResults: $0)) }
                    .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
                    .eraseToAnyPublisher()
            }
        case let .setSearchResults(searchResults):
            state.searchResults = searchResults
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        case let .getItemDetails(item, itemId, forced):
            return environment.dataController.getItemDetails(for: item, itemId: itemId, forced: forced, settings: state.settings, exchangeRates: state.rates)
                .map { AppAction.main(action: .setSelectedItem(item: $0)) }
                .catchErrors()
        case .setSelectedItem(let item):
            state.selectedItem = item
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        case let .addToInventory(inventoryItems):
            environment.dataController.add(inventoryItems: inventoryItems)
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        //    case let .removeFromInventory(inventoryItem):
        //        return environment.functions.removeFromInventory(userId: state.mainState.userId, inventoryItem: inventoryItem)
        //            .map { AppAction.main(action: .removeInventoryItems(inventoryItems: [inventoryItem])) }
        //            .catchErrors()
        //    case let .setInventoryItems(inventoryItems):
        //        inventoryItems.forEach { inventoryItem in
        //            if let index = state.mainState.inventoryItems.firstIndex(where: { $0.id == inventoryItem.id }) {
        //                state.mainState.inventoryItems[index] = inventoryItem
        //            } else {
        //                state.mainState.inventoryItems.append(inventoryItem)
        //            }
        //        }
        //        return Empty(completeImmediately: true).eraseToAnyPublisher()
        //    case let .removeInventoryItems(inventoryItems):
        //        inventoryItems.forEach { inventoryItem in
        //            if let index = state.mainState.inventoryItems.firstIndex(where: { $0.id == inventoryItem.id }) {
        //                state.mainState.inventoryItems.remove(at: index)
        //            }
        //        }
        //        return Empty(completeImmediately: true).eraseToAnyPublisher()
        //    case .getInventoryItems:
        //        return environment.functions.getInventoryItems(userId: state.mainState.userId)
        //            .map { AppAction.main(action: .setInventoryItems(inventoryItems: $0)) }
        //            .catchErrors()
        case .getExchangeRates:
            return environment.dataController.getExchangeRates(settings: state.settings, exchangeRates: state.rates)
                .map {
                    environment.dataController.add(exchangeRates: $0)
                    return AppAction.none
                }
                .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
                .eraseToAnyPublisher()
        }
    case let .authentication(action: action):
        return environment.authenticator.handle(action)
            .flatMap { userId -> AnyPublisher<AppAction, Never> in
                if userId.isEmpty {
                    return Just(AppAction.main(action: .signOut)).eraseToAnyPublisher()
                } else {
                    environment.dataController.setup(userId: userId)
                    return environment.dataController.getUser(withId: userId)
                        .flatMap { Just(AppAction.main(action: .setUser(user: $0))) }
                        .tryCatch {
                            Just(AppAction.main(action: .signOut)).merge(with: Just(AppAction.error(action: .setError(error: AppError(error: $0)))))
                        }
                        .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
                        .eraseToAnyPublisher()
                }
            }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    case let .error(action: action):
        switch action {
        case let .setError(error: error):
            state.error = error
        }
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
}
