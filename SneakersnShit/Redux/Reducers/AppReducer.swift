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
    log("processing: \(action.id)", logType: .reduxAction)
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
        case let .updateProfileVisibility(isPublic):
            if var updatedUser = state.user {
                updatedUser.isPublic = isPublic
                environment.dataController.update(user: updatedUser)
                if !isPublic {
                    let stacksToUpdate = state.stacks
                        .filter { $0.isPublic == true || $0.isPublished == true }
                        .map { (stack: Stack) -> Stack in
                            var updatedStack = stack
                            updatedStack.isPublished = false
                            updatedStack.isPublic = false
                            return updatedStack
                        }
                    environment.dataController.update(stacks: stacksToUpdate)
                }
            }
        case let .getFeedPosts(loadMore):
            return environment.dataController.getFeedPosts(loadMore: loadMore)
                .map { (result: PaginatedResult<[FeedPost]>) in
                    if loadMore {
                        return AppAction.main(action: .addFeedPosts(feedPosts: result))
                    } else {
                        return AppAction.main(action: .setFeedPosts(feedPosts: result))
                    }
                }
                .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
                .eraseToAnyPublisher()
        case let .setFeedPosts(postsData):
            state.feedPosts = postsData
        case let .addFeedPosts(postsData):
            state.feedPosts.data += postsData.data
            state.feedPosts.isLastPage = postsData.isLastPage
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
        case let .getUserProfile(userId, completion):
            return environment.dataController.getUserProfile(userId: userId)
                .map { (user: ProfileData) in AppAction.main(action: .setSelectedUser(user: user, completion: completion)) }
                .catchErrors()
        case let .setSelectedUser(user, completion):
            var newUser = user
            #warning("fix")
//            if state.selectedUserProfile?.user.imageURL != nil {
//                if state.selectedUserProfile?.user.id == user?.user.id {
//                    newUser?.user.imageURL = state.selectedUserProfile?.user.imageURL
//                }
//            } else {
//                if let user = state.userSearchResults.first(where: { $0.id == newUser?.user.id }), user.imageURL != nil {
//                    newUser?.user.imageURL = user.imageURL
//                }
//            }
            completion(newUser)
        case let .getItemDetails(item, itemId, fetchMode, completion):
            return environment.dataController.getItemDetails(for: item,
                                                             itemId: itemId,
                                                             fetchMode: fetchMode,
                                                             settings: state.settings,
                                                             exchangeRates: state.rates)
                .map { AppAction.main(action: .setSelectedItem(item: $0, completion: completion)) }
                .catchErrors()
        case let .getItemImage(itemId, completion):
            environment.dataController.getImage(for: itemId, completion: completion)
        case let .uploadItemImage(itemId, image):
            DispatchQueue.main.async {
                environment.dataController.uploadItemImage(itemId: itemId, image: image)
            }
        case let .refreshItemIfNeeded(itemId, fetchMode):
            return environment.dataController.getItemDetails(for: nil,
                                                             itemId: itemId,
                                                             fetchMode: fetchMode,
                                                             settings: state.settings,
                                                             exchangeRates: state.rates)
                .map { _ in AppAction.none }
                .catchErrors()
        case let .setSelectedItem(item, completion):
            if let item = item {
                ItemCache.default.insert(item: item, settings: state.settings)
            }
            completion(item)
        case let .addStack(stack):
            environment.dataController.update(stacks: [stack])
        case let .deleteStack(stack):
            environment.dataController.delete(stack: stack)
        case let .updateStack(stack):
            if stack.id != "all" {
                environment.dataController.update(stacks: [stack])
                if state.user?.isPublic != true, stack.isPublished == true || stack.isPublic == true {
                    return Just(AppAction.main(action: .updateProfileVisibility(isPublic: true))).eraseToAnyPublisher()
                }
            }
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
                        .flatMap {
                            Just(AppAction.main(action: .setUser(user: $0)))
                        }
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
