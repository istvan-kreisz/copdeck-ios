//
//  DefaultBackendAPI.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Combine
import FirebaseFunctions

class DefaultBackendAPI: FBFunctionsCoordinator, BackendAPI  {
    #warning("fix")
    func getFeedPosts() -> AnyPublisher<[FeedPostData], AppError> {
        struct Wrapper: Encodable {
            let userId: String?
        }
        return callFirebaseFunctionArray(functionName: "getFeedPosts", model: Wrapper(userId: userId))
    }

    func search(searchTerm: String, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError> {
        callFirebaseFunction(functionName: "search", model: searchTerm)
    }

    func update(item: Item, settings: CopDeckSettings) {
        struct Wrapper: Encodable {
            let userId: String?
            let item: Item
            let settings: CopDeckSettings
        }
        handlePublisherResult(publisher: callFirebaseFunction(functionName: "updateItem", model: Wrapper(userId: userId, item: item, settings: settings)))
    }

    func add(inventoryItems: [InventoryItem]) {
        struct Wrapper: Encodable {
            let userId: String?
            let inventoryItems: [InventoryItem]
        }
        handlePublisherResult(publisher: callFirebaseFunction(functionName: "addInventoryItems",
                                                              model: Wrapper(userId: userId, inventoryItems: inventoryItems)))
    }

    func delete(inventoryItems: [InventoryItem]) {
        struct Wrapper: Encodable {
            let userId: String?
            let inventoryItemIds: [String]
        }
        handlePublisherResult(publisher: callFirebaseFunction(functionName: "deleteInventoryItems",
                                                              model: Wrapper(userId: userId, inventoryItemIds: inventoryItems.map(\.id))))
    }

    func update(inventoryItem: InventoryItem) {
        struct Wrapper: Encodable {
            let userId: String?
            let inventoryItem: InventoryItem
        }
        handlePublisherResult(publisher: callFirebaseFunction(functionName: "updateInventoryItem",
                                                              model: Wrapper(userId: userId, inventoryItem: inventoryItem)))
    }

    func update(stack: Stack) {
        struct Wrapper: Encodable {
            let userId: String?
            let stack: Stack
        }
        handlePublisherResult(publisher: callFirebaseFunction(functionName: "updateStack", model: Wrapper(userId: userId, stack: stack)))
    }

    func delete(stack: Stack) {
        struct Wrapper: Encodable {
            let userId: String?
            let stackId: String
        }
        handlePublisherResult(publisher: callFirebaseFunction(functionName: "deleteStack", model: Wrapper(userId: userId, stackId: stack.id)))
    }

    func deleteUser() {
        struct Wrapper: Encodable {
            let userId: String?
        }
        handlePublisherResult(publisher: callFirebaseFunction(functionName: "deleteUser", model: Wrapper(userId: userId)))
    }

    func update(user: User) {
        struct Wrapper: Encodable {
            let userId: String?
            let user: User
        }
        handlePublisherResult(publisher: callFirebaseFunction(functionName: "updateUser", model: Wrapper(userId: userId, user: user)))
    }

    func getUserProfile(userId: String) -> AnyPublisher<ProfileData, AppError> {
        struct Wrapper: Encodable {
            let userId: String
        }
        return callFirebaseFunction(functionName: "getUserProfile", model: Wrapper(userId: userId))
    }

    func searchUsers(searchTerm: String) -> AnyPublisher<[User], AppError> {
        struct Wrapper: Encodable {
            let searchTerm: String
        }
        return callFirebaseFunctionArray(functionName: "searchUsers", model: Wrapper(searchTerm: searchTerm))
    }
}
