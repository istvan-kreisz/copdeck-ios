//
//  MainReducer.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation
import Combine

func mainReducer(state: inout AppState,
                 action: MainAction,
                 environment: Main) -> AnyPublisher<AppAction, Never> {
    switch action {
    case let .setUserId(userId):
        state.authenticationState.userId = userId
        state.mainState.userId = userId
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .setUser(user):
        state.mainState.user = user
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .getUserData(userId: userId):
        print(userId)
//        return environment.functions.getUserData(userId: userId)
//            .map { AppAction.main(action: .setUser($0, userId)) }
//            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
//            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
//            .eraseToAnyPublisher()
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .changeUsername(newName: newName):
        print(newName)
//        let userId = state.mainState.userId
//        return environment.functions.changeUsername(userId: userId, newName: newName)
//            .map { AppAction.main(action: .setUser($0, userId)) }
//            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
//            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
//            .eraseToAnyPublisher()
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .getSearchResults(searchTerm: searchTerm):
        if searchTerm.isEmpty {
            return Just(AppAction.main(action: .setSearchResults([]))).eraseToAnyPublisher()
        } else {
            return environment.api.search(searchTerm: searchTerm)
                .map { AppAction.main(action: .setSearchResults($0)) }
                .catchErrors()
        }
    case let .setSearchResults(searchResult):
        state.mainState.searchResults = searchResult
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .getItemDetails(item):
        return environment.api.getItemDetails(for: item)
            .map { AppAction.main(action: .setItemDetails(item: $0)) }
            .catchErrors()
    case let .setItemDetails(item):
        state.mainState.selectedItem = item
        return Empty(completeImmediately: true).eraseToAnyPublisher()
//    case let .addToInventory(inventoryItem):
//        return environment.functions.addToInventory(userId: state.mainState.userId, inventoryItem: inventoryItem)
//            .map { AppAction.main(action: .setInventoryItems(inventoryItems: [$0])) }
//            .catchErrors()
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
    }
}
