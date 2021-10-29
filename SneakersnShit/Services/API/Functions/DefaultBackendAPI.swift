//
//  DefaultBackendAPI.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Combine
import FirebaseFunctions

class DefaultBackendAPI: FBFunctionsCoordinator, BackendAPI {
    private var feedPagination = PaginationState<FeedPost>(lastLoaded: nil, isLastPage: false)

    func getFeedPosts(loadMore: Bool) -> AnyPublisher<PaginatedResult<[FeedPost]>, AppError> {
        struct Wrapper: Encodable {
            let userId: String?
            let startAfter: [String]?
        }
        struct Result: Codable, Equatable {
            var posts: [FeedPost]
            let users: [User]
        }
        var model: Wrapper
        if loadMore {
            if let lastLoadedFeedPost = feedPagination.lastLoaded, !feedPagination.isLastPage {
                let lastLoadedStackPath = ["users", lastLoadedFeedPost.userId, "stacks", lastLoadedFeedPost.stack.id]
                model = .init(userId: userId, startAfter: lastLoadedStackPath)
            } else {
                feedPagination.reset()
                return Just(.init(data: [], isLastPage: true)).setFailureType(to: AppError.self).eraseToAnyPublisher()
            }
        } else {
            feedPagination.reset()
            model = .init(userId: userId, startAfter: nil)
        }
        let result: AnyPublisher<PaginatedResult<Result>, AppError> = callFirebaseFunction(functionName: "getFeedPosts", model: model)
        return result
            .map { result in
                let updatedPosts = result.data.posts.map { (post: FeedPost) -> FeedPost in
                    var updatedPost = post
                    updatedPost.user = result.data.users.first(where: { $0.id == post.userId })
                    return updatedPost
                }
                return PaginatedResult(data: updatedPosts, isLastPage: result.isLastPage)
            }
            .handleEvents(receiveOutput: { [weak self] result in
                if let lastPost = result.data.sortedByDate(sortOrder: .descending).last {
                    self?.feedPagination.lastLoaded = lastPost
                }
                self?.feedPagination.isLastPage = result.isLastPage
            })
            .eraseToAnyPublisher()
    }

    func getAffiliateList(completion: @escaping (Result<[ReferralCode], Error>) -> Void) {
        struct Wrapper: Encodable {
            let userId: String?
        }
        let result: AnyPublisher<[ReferralCode], AppError> = callFirebaseFunctionArray(functionName: "getReferralCodes", model: Wrapper(userId: userId))

        result
            .sink { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                default:
                    break
                }
            } receiveValue: { completion(.success($0)) }
            .store(in: &cancellables)
    }

    func updateLike(onStack stack: Stack, addLike: Bool, stackOwnerId: String) {
        struct Wrapper: Encodable {
            let stackId: String
            let addLike: Bool
            let stackOwnerId: String
        }
        handlePublisherResult(publisher: callFirebaseFunction(functionName: "updateLike",
                                                              model: Wrapper(stackId: stack.id, addLike: addLike, stackOwnerId: stackOwnerId)))
    }

    func search(searchTerm: String, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError> {
        struct Wrapper: Encodable {
            let searchTerm: String
            let apiConfig: APIConfig
            let requestId: String
        }
        let model = Wrapper(searchTerm: searchTerm, apiConfig: DefaultDataController.config(from: settings, exchangeRates: exchangeRates), requestId: "1")
        let result: AnyPublisher<WrappedResult<[Item]>, AppError> = callFirebaseFunction(functionName: "search", model: model)
        return result.map(\.res).eraseToAnyPublisher()
    }

    func update(item: Item, settings: CopDeckSettings) {
        struct Wrapper: Encodable {
            let userId: String?
            let item: Item
            let settings: CopDeckSettings
        }
        handlePublisherResult(publisher: callFirebaseFunction(functionName: "updateItem", model: Wrapper(userId: userId, item: item, settings: settings)),
                              showAlert: false)
    }

    func getPopularItems(settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError> {
        struct Wrapper: Encodable {
            let apiConfig: APIConfig
            let requestId: String
        }
        let model = Wrapper(apiConfig: DefaultDataController.config(from: settings, exchangeRates: exchangeRates), requestId: "1")
        let result: AnyPublisher<WrappedResult<[Item]>, AppError> = callFirebaseFunction(functionName: "getPopularItems", model: model)
        return result.map(\.res).eraseToAnyPublisher()
    }

    func getItemDetails(for item: Item, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        struct Wrapper: Encodable {
            let item: Item
            let apiConfig: APIConfig
            let requestId: String
        }
        let model = Wrapper(item: item, apiConfig: DefaultDataController.config(from: settings, exchangeRates: exchangeRates), requestId: "1")
        let result: AnyPublisher<WrappedResult<Item>, AppError> = callFirebaseFunction(functionName: "getItemDetails", model: model)
        return result.map(\.res).eraseToAnyPublisher()
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

    func update(stacks: [Stack]) {
        #warning("rewrite if reenabled")
        struct Wrapper: Encodable {
            let userId: String?
            let stack: Stack
        }
        stacks.forEach { stack in
            handlePublisherResult(publisher: callFirebaseFunction(functionName: "updateStack", model: Wrapper(userId: userId, stack: stack)))
        }
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
            let profileId: String
        }
        return callFirebaseFunction(functionName: "getUserProfile", model: Wrapper(profileId: userId))
    }

    func searchUsers(searchTerm: String) -> AnyPublisher<[User], AppError> {
        struct Wrapper: Encodable {
            let searchTerm: String
        }
        return callFirebaseFunctionArray(functionName: "searchUsers", model: Wrapper(searchTerm: searchTerm))
    }

    func startSpreadsheetImport(urlString: String, completion: @escaping (Error?) -> Void) {
        struct Wrapper: Encodable {
            let urlString: String
        }
        callFirebaseFunction(functionName: "startSpreadsheetImport", model: Wrapper(urlString: urlString))
            .sink { result in
                switch result {
                case let .failure(error):
                    completion(error)
                default:
                    break
                }
            } receiveValue: { _ in completion(nil) }
            .store(in: &cancellables)
    }

    func revertLastImport(completion: @escaping (Error?) -> Void) {
        guard let userId = userId else { return }
        struct Wrapper: Encodable {
            let userId: String
        }
        callFirebaseFunction(functionName: "revertLastImport", model: Wrapper(userId: userId))
            .sink { result in
                switch result {
                case let .failure(error):
                    completion(error)
                default:
                    break
                }
            } receiveValue: { completion(nil) }
            .store(in: &cancellables)
    }

    #warning("refactor - more uniform error handling too")
    func updateSpreadsheetImportStatus(importedUserId: String,
                                       spreadSheetImportStatus: User.SpreadSheetImportStatus,
                                       spreadSheetImportError: String?,
                                       completion: @escaping (Result<User, Error>) -> Void) {
        struct Wrapper: Encodable {
            let importedUserId: String
            let spreadSheetImportStatus: User.SpreadSheetImportStatus
            let spreadSheetImportError: String?
        }
        let model = Wrapper(importedUserId: importedUserId, spreadSheetImportStatus: spreadSheetImportStatus, spreadSheetImportError: spreadSheetImportError)
        let result: AnyPublisher<User, AppError> = callFirebaseFunction(functionName: "updateSpreadsheetImportStatus", model: model)
        result
            .sink { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                default:
                    break
                }
            } receiveValue: { (user: User) in completion(.success(user)) }
            .store(in: &cancellables)
    }

    func runImport(importedUserId: String, completion: @escaping (Result<User, Error>) -> Void) {
        struct Wrapper: Encodable {
            let importedUserId: String
        }
        let result: AnyPublisher<User, AppError> = callFirebaseFunction(functionName: "runImport", model: Wrapper(importedUserId: importedUserId))
        result
            .sink { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                default:
                    break
                }
            } receiveValue: { (user: User) in completion(.success(user)) }
            .store(in: &cancellables)
    }

    func finishImport(importedUserId: String, completion: @escaping (Result<User, Error>) -> Void) {
        struct Wrapper: Encodable {
            let importedUserId: String
        }
        let result: AnyPublisher<User, AppError> = callFirebaseFunction(functionName: "finishImport", model: Wrapper(importedUserId: importedUserId))
        result
            .sink { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                default:
                    break
                }
            } receiveValue: { (user: User) in completion(.success(user)) }
            .store(in: &cancellables)
    }

    func getImportedInventoryItems(importedUserId: String, completion: @escaping (Result<[InventoryItem], Error>) -> Void) {
        struct Wrapper: Encodable {
            let importedUserId: String
        }
        let result: AnyPublisher<[InventoryItem], AppError> = callFirebaseFunctionArray(functionName: "getImportedInventoryItems",
                                                                                        model: Wrapper(importedUserId: importedUserId))
        result
            .sink { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                default:
                    break
                }
            } receiveValue: { (items: [InventoryItem]) in completion(.success(items)) }
            .store(in: &cancellables)
    }

    func applyReferralCode(_ code: String, completion: ((Result<Void, AppError>) -> Void)?) {
        struct Wrapper: Encodable {
            let referralCode: String
        }
        handlePublisherResult(publisher: callFirebaseFunction(functionName: "applyReferralCode", model: Wrapper(referralCode: code)), completion: completion)
    }

    func userSubscribed() {
        struct Wrapper: Encodable {
            let userId: String?
        }
        handlePublisherResult(publisher: callFirebaseFunction(functionName: "userSubscribed", model: Wrapper(userId: userId)), showAlert: false)
    }

    func sendMessage(email: String, message: String, completion: ((Result<Void, AppError>) -> Void)?) {
        struct Wrapper: Encodable {
            let email: String
            let message: String
        }
        handlePublisherResult(publisher: callFirebaseFunction(functionName: "sendMessage", model: Wrapper(email: email, message: message)),
                              completion: completion)
    }
}
