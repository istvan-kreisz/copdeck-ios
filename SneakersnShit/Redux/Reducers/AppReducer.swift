//
//  AppReducer.swift
//  CopDeck
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation
import Combine

func appReducer(state: inout AppState,
                action: AppAction,
                environment: World,
                completed: ((Result<Void, AppError>) -> Void)?) -> AnyPublisher<AppAction, Never> {
    log("processing: \(action.id)")
    switch action {
    case .none:
        break
    case let .main(action: action):
        switch action {
        case .signOut:
            state.reset()
            if !state.firstLoadDone {
                state.firstLoadDone = true
            }
            environment.dataController.reset()
        case let .setUser(user):
            if !state.firstLoadDone {
                state.firstLoadDone = true
            }
            state.user = user
            environment.dataController.setup(userId: user.id)
        case let .updateUsername(username):
            if var updatedUser = state.user {
                updatedUser.name = username
                environment.dataController.update(user: updatedUser)
            }
        case .getFeedPosts:
            return environment.dataController.getFeedPosts()
                .map { (feedPosts: [FeedPostData]) in AppAction.main(action: .setFeedPosts(feedPosts)) }
                .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
                .eraseToAnyPublisher()
        case let .setFeedPosts(postsData):
            state.feedPosts += postsData
        case let .updateSettings(settings):
            if var updatedUser = state.user {
                updatedUser.settings = settings
                updatedUser.inited = true
                environment.dataController.update(user: updatedUser)
            }
        case let .getSearchResults(searchTerm: searchTerm):
            if searchTerm.isEmpty {
                state.searchResults = []
            } else {
                return environment.dataController.search(searchTerm: searchTerm, settings: state.settings, exchangeRates: state.rates)
                    .map { (items: [Item]) in AppAction.main(action: .setSearchResults(searchResults: items)) }
                    .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
                    .eraseToAnyPublisher()
            }
        case let .setSearchResults(searchResults):
            state.searchResults = searchResults
        case .getPopularItems:
            return environment.dataController.getPopularItems(settings: state.settings, exchangeRates: state.rates)
                .map { (items: [Item]) in AppAction.main(action: .setPopularItems(items: items)) }
                .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
                .eraseToAnyPublisher()
        case let .setPopularItems(items):
            state.popularItems = items
        case let .searchUsers(searchTerm):
            return environment.dataController.searchUsers(searchTerm: searchTerm)
                .map { (users: [User]) in AppAction.main(action: .setUserSearchResults(searchResults: users)) }
                .catchErrors()
        case let .setUserSearchResults(searchResults):
            state.userSearchResults = searchResults
        case let .favorite(item):
            environment.dataController.favorite(item: item)
        case let .unfavorite(item):
            environment.dataController.unfavorite(item: item)
        case let .addRecentlyViewed(item):
            environment.dataController.add(recentlyViewedItem: item)
        case let .getUserProfile(userId):
            return environment.dataController.getUserProfile(userId: userId)
                .map { (user: ProfileData) in AppAction.main(action: .setSelectedUser(user: user)) }
                .catchErrors()
        case let .setSelectedUser(user):
            var newUser = user
            if state.selectedUserProfile?.user.imageURL != nil {
                if state.selectedUserProfile?.user.id == user?.user.id {
                    newUser?.user.imageURL = state.selectedUserProfile?.user.imageURL
                }
            } else {
                if let user = state.userSearchResults.first(where: { $0.id == newUser?.user.id }), user.imageURL != nil {
                    newUser?.user.imageURL = user.imageURL
                }
            }
            state.selectedUserProfile = newUser
        case let .getItemDetails(item, itemId, fetchMode):
            return environment.dataController.getItemDetails(for: item,
                                                             itemId: itemId,
                                                             fetchMode: fetchMode,
                                                             settings: state.settings,
                                                             exchangeRates: state.rates)
                .map { AppAction.main(action: .setSelectedItem(item: $0)) }
                .catchErrors()
        case let .refreshItemIfNeeded(itemId, fetchMode):
            return environment.dataController.getItemDetails(for: nil,
                                                             itemId: itemId,
                                                             fetchMode: fetchMode,
                                                             settings: state.settings,
                                                             exchangeRates: state.rates)
                .map { _ in AppAction.none }
                .catchErrors()
        case .setSelectedItem(let item):
            state.selectedItem = item
            if let item = item {
                ItemCache.default.insert(item: item, settings: state.settings)
            }
        case let .addStack(stack):
            environment.dataController.update(stack: stack)
        case let .deleteStack(stack):
            environment.dataController.delete(stack: stack)
        case let .updateStack(stack):
            environment.dataController.update(stack: stack)
        case let .addToInventory(inventoryItems):
            environment.dataController.add(inventoryItems: inventoryItems)
        case let .updateInventoryItem(inventoryItem: InventoryItem):
            environment.dataController.update(inventoryItem: InventoryItem)
        case let .removeFromInventory(inventoryItems):
            environment.dataController.delete(inventoryItems: inventoryItems)
        case let .stack(inventoryItems, stack):
            environment.dataController.stack(inventoryItems: inventoryItems, stack: stack)
        case let .unstack(inventoryItems, stack):
            environment.dataController.unstack(inventoryItems: inventoryItems, stack: stack)
        case let .uploadProfileImage(profileImage):
            environment.dataController.uploadProfileImage(image: profileImage)
        }
    case let .authentication(action: action):
        return environment.authenticator.handle(action)
            .flatMap { userId -> AnyPublisher<AppAction, Never> in
                if userId.isEmpty {
                    return Just(AppAction.main(action: .signOut)).eraseToAnyPublisher()
                } else {
                    return environment.dataController.getUser(withId: userId)
                        .flatMap { Just(AppAction.main(action: .setUser(user: $0))) }
                        .tryCatch {
                            Just(AppAction.main(action: .signOut)).merge(with: Just(AppAction.error(action: .setError(error: AppError(error: $0)))))
                        }
                        .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
                        .eraseToAnyPublisher()
                }
            }
            .tryCatch {
                Just(AppAction.error(action: .setError(error: AppError(error: $0))))
            }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    case let .error(action: action):
        switch action {
        case let .setError(error: error):
            state.error = error
        }
    }
    return Empty(completeImmediately: true).eraseToAnyPublisher()
}
