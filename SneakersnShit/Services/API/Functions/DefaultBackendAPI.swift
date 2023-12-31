//
//  DefaultBackendAPI.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Combine
import FirebaseFunctions
import SwiftUI

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

    func refreshUserSubscriptionStatus(completion: ((Result<Void, AppError>) -> Void)?) {
        guard let userId = userId else { return }
        struct Body: Encodable {
            struct Event: Encodable {
                let original_app_user_id: String
            }

            let event: Event
        }
        let body = Body(event: .init(original_app_user_id: userId))

        #warning("test and change to local if functions emulator enabled")
        guard let url = URL(string: "https://europe-west1-sneakersnshit-2e22f.cloudfunctions.net/refreshUserSubscriptionStatus"),
              let httpBody = try? JSONEncoder().encode(body)
        else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(DefaultPaymentService.apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            let statusMessage = data.map { String(decoding: $0, as: UTF8.self) } ?? ""
            let appError = error.map { AppError(error: $0) }
            let error = appError ?? AppError(title: "Error", message: statusMessage, error: nil)

            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    if statusMessage.isEmpty || statusMessage.lowercased() == "ok" {
                        completion?(.success(()))
                    } else {
                        completion?(.failure(error))
                    }
                } else {
                    completion?(.failure(error))
                }
            } else {
                completion?(.failure(error))
            }
        }.resume()
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

    func search(searchTerm: String, settings: CopDeckSettings, exchangeRates: ExchangeRates?) -> AnyPublisher<[ItemSearchResult], AppError> {
        struct Wrapper: Encodable {
            let searchTerm: String
            let apiConfig: APIConfig
        }
        let model = Wrapper(searchTerm: searchTerm, apiConfig: DefaultDataController.config(from: settings, exchangeRates: exchangeRates))
        let result: AnyPublisher<[ItemSearchResult], AppError> = callFirebaseFunctionArray(functionName: "searchV2", model: model)
        return result.eraseToAnyPublisher()
    }

    func update(item: Item, forced: Bool, settings: CopDeckSettings, exchangeRates: ExchangeRates?, completion: @escaping () -> Void) {
        struct Wrapper: Encodable {
            let item: Item
            let apiConfig: APIConfig
            let forced: Bool
        }
        let model = Wrapper(item: item, apiConfig: DefaultDataController.config(from: settings, exchangeRates: exchangeRates), forced: forced)
        callFirebaseFunction(functionName: "updateItemV2", model: model)
            .sink { result in
                completion()
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func updateInventoryPrices(completion: @escaping () -> Void) {
        guard let userId = userId else {
            completion()
            return
        }
        struct Wrapper: Encodable {
            let userId: String
        }
        let model = Wrapper(userId: userId)
        callFirebaseFunction(functionName: "updateUserItems", model: model)
            .timeout(.seconds(545), scheduler: DispatchQueue.main)
            .sink { result in
                completion()
            } receiveValue: { _ in }
            .store(in: &cancellables)
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

    func getUsers(userIds: [String], completion: @escaping (Result<[User], AppError>) -> Void) {
        struct Wrapper: Encodable {
            let userIds: [String]
        }
        handlePublisherResult(publisher: callFirebaseFunctionArray(functionName: "getUsers", model: Wrapper(userIds: userIds)),
                              showAlert: false,
                              completion: completion)
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

    func sendMessage(email: String, message: String, completion: ((Result<Void, AppError>) -> Void)?) {
        struct Wrapper: Encodable {
            let email: String
            let message: String
        }
        handlePublisherResult(publisher: callFirebaseFunction(functionName: "sendMessage", model: Wrapper(email: email, message: message)),
                              completion: completion)
    }

    func deleteAccount() {
        guard let userId = userId else { return }
        struct Wrapper: Encodable {
            let userId: String
        }
        handlePublisherResult(publisher: callFirebaseFunction(functionName: "deleteAccount", model: Wrapper(userId: userId)),
                              showAlert: true,
                              completion: nil)
    }
}
