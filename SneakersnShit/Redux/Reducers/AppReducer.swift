//
//  AppReducer.swift
//  CopDeck
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation
import Combine
import Firebase

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
            FeedView.preloadedPosts = nil
            FeedView.didStartPreloading = false
            ChatView.preloadedChannels = []
            ChatView.didStartPreloading = false
            environment.dataController.reset()
            environment.paymentService.reset()
            environment.pushNotificationService.reset()
        // delete tokens
        case let .setUser(user):
            if !state.firstLoadDone {
                state.firstLoadDone = true
            }
            state.user = user
            environment.pushNotificationService.setup(userId: user.id)
            environment.dataController.setup(userId: user.id)
            environment.paymentService.setup(userId: user.id, userEmail: user.email)
        // register tokens
        case let .updateUsername(username):
            Analytics.logEvent("update_username", parameters: ["userId": state.user?.id ?? ""])
            if var updatedUser = state.user {
                updatedUser.name = username
                environment.dataController.update(user: updatedUser)
            }
        case let .addNewTag(tag: tag):
            Analytics.logEvent("add_tag", parameters: ["userId": state.user?.id ?? ""])
            if var updatedUser = state.user {
                updatedUser.tags = (updatedUser.tags ?? []) + [tag]
                environment.dataController.update(user: updatedUser)
            }
        case let .deleteTag(tag: tag):
            if var updatedUser = state.user {
                updatedUser.tags = (updatedUser.tags ?? []).filter { $0.id != tag.id }
                environment.dataController.update(user: updatedUser)
            }
            let inventoryItemsToUpdate = state.inventoryItems.filter { $0.tags.contains { t in t.id == tag.id } }
            if !inventoryItemsToUpdate.isEmpty {
                inventoryItemsToUpdate.map { inventoryItem in
                    var newInventoryItem = inventoryItem
                    newInventoryItem.tags = newInventoryItem.tags.filter { t in t.id != tag.id }
                    return newInventoryItem
                }.forEach {
                    environment.dataController.update(inventoryItem: $0)
                }
            }
        case .enabledNotifications:
            Analytics.logEvent("enable_notifications", parameters: ["userId": state.user?.id ?? ""])
            if var updatedUser = state.user, updatedUser.notificationsEnabled != true {
                updatedUser.notificationsEnabled = true
                environment.dataController.update(user: updatedUser)
            }
        case let .getFeedPosts(loadMore, completion):
            return environment.dataController.getFeedPosts(loadMore: loadMore)
                .complete(completion: completion)
        case let .toggleLike(stack, stackOwnerId):
            if let userId = state.user?.id {
                let shouldAddLike = stack.likes?.contains(userId) == true
                if shouldAddLike {
                    Analytics.logEvent("like_stack", parameters: ["userId": state.user?.id ?? ""])
                }
                environment.dataController.updateLike(onStack: stack, addLike: shouldAddLike, stackOwnerId: stackOwnerId)
            }
        case let .updateSettings(settings):
            Analytics.logEvent("update_settings", parameters: ["userId": state.user?.id ?? ""])
            if var updatedUser = state.user {
                updatedUser.settings = settings
                updatedUser.inited = true
                environment.dataController.update(user: updatedUser)
            }
        case let .getSearchResults(searchTerm: searchTerm, completion: completion):
            Analytics.logEvent("search_items", parameters: ["userId": state.user?.id ?? ""])
            if searchTerm.isEmpty {
                completion(.success([]))
            } else {
                return environment.dataController.search(searchTerm: searchTerm, settings: state.settings, exchangeRates: state.rates)
                    .complete(completion: completion)
            }
        case let .getPopularItems(completion: completion):
            return environment.dataController.getPopularItems()
                .complete(completion: completion)
        case let .searchUsers(searchTerm: searchTerm, completion: completion):
            Analytics.logEvent("search_users", parameters: ["userId": state.user?.id ?? ""])
            return environment.dataController.searchUsers(searchTerm: searchTerm)
                .complete(completion: completion)
        case let .favorite(item):
            Analytics.logEvent("favorite_item", parameters: ["userId": state.user?.id ?? ""])
            environment.dataController.favorite(item: item)
        case let .unfavorite(item):
            environment.dataController.unfavorite(item: item)
        case let .addRecentlyViewed(item):
            environment.dataController.add(recentlyViewedItem: item)
        case let .getUserProfile(userId, completion):
            return environment.dataController.getUserProfile(userId: userId)
                .complete { completion($0.value) }
        case let .updateItem(item, itemId, styleId, forced, completion):
            environment.dataController.update(item: item,
                                              itemId: itemId,
                                              styleId: styleId,
                                              forced: forced,
                                              settings: state.settings,
                                              exchangeRates: state.exchangeRates,
                                              completion: completion)
        case let .getItemListener(itemId, updated, completion):
            completion(environment.dataController.getItemListener(withId: itemId, settings: state.settings, updated: updated))
        case let .getItemImage(itemId, completion):
            environment.dataController.getImage(for: itemId, completion: completion)
        case let .uploadItemImage(itemId, image):
            environment.dataController.uploadItemImage(itemId: itemId, image: image)
        case let .updateInventoryItems(associatedWith: item):
            AppStore.default.updateInventoryItems(associatedWith: item)
        case let .addStack(stack):
            Analytics.logEvent("add_stack", parameters: ["userId": state.user?.id ?? ""])
            environment.dataController.update(stacks: [stack])
        case let .deleteStack(stack):
            environment.dataController.delete(stack: stack)
        case let .updateStack(stack):
            if stack.id != "all" {
                environment.dataController.update(stacks: [stack])
            }
        case let .addToInventory(inventoryItems):
            Analytics.logEvent("add_inventoryitem", parameters: ["userId": state.user?.id ?? ""])

            let userId = state.user?.id ?? ""
            environment.dataController.add(inventoryItems: inventoryItems) { result in
                if case let .success(inventoryItems) = result, inventoryItems.contains(where: { !$0._addToStacks.isEmpty }) {
                    inventoryItems
                        .filter { !$0._addToStacks.isEmpty }
                        .forEach { inventoryItem in
                            Analytics.logEvent("stack_inventoryitems", parameters: ["userId": userId])
                            inventoryItem._addToStacks.forEach { stack in
                                environment.dataController.stack(inventoryItems: [inventoryItem], stack: stack)
                            }
                        }
                }
            }
        case let .updateInventoryItem(inventoryItem: inventoryItem):
            environment.dataController.update(inventoryItem: inventoryItem)
        case let .removeFromInventory(inventoryItems):
            environment.dataController.delete(inventoryItems: inventoryItems)
        case let .stack(inventoryItems, stack):
            Analytics.logEvent("stack_inventoryitems", parameters: ["userId": state.user?.id ?? ""])
            environment.dataController.stack(inventoryItems: inventoryItems, stack: stack)
        case let .unstack(inventoryItems, stack):
            environment.dataController.unstack(inventoryItems: inventoryItems, stack: stack)
        case let .uploadProfileImage(profileImage):
            environment.dataController.uploadProfileImage(image: profileImage)
        case let .getInventoryItemImages(userId, inventoryItem, completion):
            environment.dataController.getInventoryItemImages(userId: userId, inventoryItem: inventoryItem, completion: completion)
        case let .uploadInventoryItemImages(inventoryItem, images, completion):
            Analytics.logEvent("upload_inventoryitem_images", parameters: ["userId": state.user?.id ?? ""])
            environment.dataController.uploadInventoryItemImages(inventoryItem: inventoryItem, images: images, completion: completion)
        case let .deleteInventoryItemImage(imageURL, completion):
            environment.dataController.deleteInventoryItemImage(imageURL: imageURL, completion: completion)
        case let .deleteInventoryItemImages(inventoryItem):
            environment.dataController.deleteInventoryItemImages(inventoryItem: inventoryItem)
        case let .startSpreadsheetImport(urlString, completion):
            Analytics.logEvent("start_spreadsheet_import", parameters: ["userId": state.user?.id ?? ""])
            environment.dataController.startSpreadsheetImport(urlString: urlString, completion: completion)
        case let .revertLastImport(completion):
            Analytics.logEvent("revert_spreadsheet_import", parameters: ["userId": state.user?.id ?? ""])
            environment.dataController.revertLastImport(completion: completion)
        case let .getSpreadsheetImportWaitlist(completion):
            environment.dataController.getSpreadsheetImportWaitlist(completion: completion)
        case let .updateSpreadsheetImportStatus(importedUserId, spreadSheetImportStatus, spreadSheetImportError, completion):
            environment.dataController.updateSpreadsheetImportStatus(importedUserId: importedUserId,
                                                                     spreadSheetImportStatus: spreadSheetImportStatus,
                                                                     spreadSheetImportError: spreadSheetImportError,
                                                                     completion: completion)
        case let .runImport(importedUserId, completion):
            environment.dataController.runImport(importedUserId: importedUserId, completion: completion)
        case let .finishImport(importedUserId, completion):
            environment.dataController.finishImport(importedUserId: importedUserId, completion: completion)
        case let .getImportedInventoryItems(importedUserId, completion):
            environment.dataController.getImportedInventoryItems(importedUserId: importedUserId, completion: completion)
        case let .getAffiliateList(completion):
            environment.dataController.getAffiliateList(completion: completion)
        case let .sendMessage(email, message, completion):
            environment.dataController.sendMessage(email: email, message: message, completion: completion)
        case let .getChannels(update):
            environment.dataController.getChannels(update: update)
        case let .getChannelListener(channelId, cancel, update):
            environment.dataController.getChannelListener(channelId: channelId, cancel: cancel, update: update)
        case let .sendChatMessage(message, channel, completion):
            Analytics.logEvent("send_message", parameters: ["userId": state.user?.id ?? ""])
            if let user = state.user {
                environment.dataController.sendMessage(user: user, message: message, toChannel: channel, completion: completion)
            } else {
                completion(.failure(.notFound(val: "User")))
            }
        case let .markChannelAsSeen(channel: channel):
            environment.dataController.markChannelAsSeen(channel: channel)
        case let .getOrCreateChannel(users: users, completion: completion):
            environment.dataController.getOrCreateChannel(users: users, completion: completion)
        }
    case let .authentication(action):
        let result: AnyPublisher<String, Error>
        var refCode: String? = nil
        switch action {
        case .restoreState:
            result = environment.authenticator.restoreState()
        case let .signUp(username, password, referralCode):
            refCode = referralCode
            result = environment.authenticator.signUp(email: username, password: password)
        case let .signIn(username, password):
            result = environment.authenticator.signIn(email: username, password: password)
        case let .signInWithApple(referralCode):
            refCode = referralCode
            result = environment.authenticator.signInWithApple()
        case let .signInWithGoogle(referralCode):
            refCode = referralCode
            result = environment.authenticator.signInWithGoogle()
        case let .signInWithFacebook(referralCode):
            refCode = referralCode
            let user = state.user
            let publisher = environment.authenticator.signInWithFacebook()
                .handleEvents(receiveOutput: { [weak environment] _, profileURL in
                    if var profile = user {
                        profile.facebookProfileURL = profileURL
                        environment?.dataController.update(user: profile)
                    }
                })
                .map(\.userId)
                .eraseToAnyPublisher()
            result = publisher
        case let .passwordReset(email):
            result = environment.authenticator.resetPassword(email: email)
        case .signOut:
            result = environment.authenticator.signOut()
        }
        return result
            .flatMap { userId -> AnyPublisher<AppAction, Never> in
                if userId.isEmpty {
                    return Just(AppAction.main(action: .signOut)).eraseToAnyPublisher()
                } else {
                    return environment.dataController.getUser(withId: userId)
                        .flatMap { (user: User) -> AnyPublisher<AppAction, Never> in
                            if let referralCode = refCode, user.membershipInfo?.referralCodeUsed == nil {
                                return Just(AppAction.main(action: .setUser(user: user)))
                                    .merge(with: Just(AppAction.paymentAction(action: .applyReferralCode(referralCode, completion: nil))))
                                    .eraseToAnyPublisher()
                            } else {
                                return Just(AppAction.main(action: .setUser(user: user))).eraseToAnyPublisher()
                            }
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
    case let .paymentAction(action):
        switch action {
        case let .applyReferralCode(code, completion):
            Analytics.logEvent("apply_referral_code", parameters: ["userId": state.user?.id ?? ""])
            environment.dataController.applyReferralCode(code, completion: completion)
        case let .purchase(package):
            environment.paymentService.purchase(package: package)
        case let .restorePurchases(completion):
            environment.dataController.refreshUserSubscriptionStatus(completion: completion)
        case let .showPaymentView(show):
            state.showPaymentView = show
        }
    }
    return Empty(completeImmediately: true).eraseToAnyPublisher()
}
