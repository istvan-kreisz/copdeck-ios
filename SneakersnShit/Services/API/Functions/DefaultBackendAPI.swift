//
//  DefaultBackendAPI.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Combine
import FirebaseFunctions

class DefaultBackendAPI: BackendAPI {
    private let functions = Functions.functions(region: "europe-west1")
    private var userId: String?
    var cancellables: Set<AnyCancellable> = []

    private let errorsSubject = PassthroughSubject<AppError, Never>()
    var errorsPublisher: AnyPublisher<AppError, Never> {
        errorsSubject.eraseToAnyPublisher()
    }

    init() {
        if DebugSettings.shared.isInDebugMode, DebugSettings.shared.useFunctionsEmulator {
            functions.useFunctionsEmulator(origin: "http://istvans-macbook-pro-2.local:5001")
        }
    }

    func setup(userId: String) {
        self.userId = userId
    }

    private func handlePublisherResult<Model>(publisher: AnyPublisher<Model, AppError>) {
        publisher
            .sink { [weak self] result in
                switch result {
                case let .failure(error):
                    self?.errorsSubject.send(error)
                case .finished:
                    break
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    #warning("fix")
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

    private func callFirebaseFunction(functionName: String, model: Encodable) -> AnyPublisher<Void, AppError> {
        firebaseFunction(functionName: functionName, model: model) { result, completion in
            completion(.success(()))
        }
    }

    private func callFirebaseFunction<Model: Decodable>(functionName: String, model: Encodable) -> AnyPublisher<Model, AppError> {
        firebaseFunction(functionName: functionName, model: model) { result, completion in
            let result: Model = try self.decodeResult(result)
            completion(.success(result))
        }
    }

    private func callFirebaseFunctionArray<Model: Decodable>(functionName: String, model: Encodable) -> AnyPublisher<[Model], AppError> {
        firebaseFunction(functionName: functionName, model: model) { result, completion in
            let result: [Model] = try self.decodeResultArray(result)
            completion(.success(result))
        }
    }

    private func firebaseFunction<Model>(functionName: String,
                                         model: Encodable,
                                         handleResult: @escaping (HTTPSCallableResult?, (Result<Model, AppError>) -> Void) throws -> Void)
        -> AnyPublisher<Model, AppError> {
        guard let userId = userId else { return Fail(error: AppError.unauthenticated).eraseToAnyPublisher() }
        do {
            var parameters = try model.asDictionary()
            parameters["userId"] = userId
            return Future<Model, AppError> { [weak self] completion in
                self?.functions.httpsCallable(functionName).call(parameters) { [weak self] result, error in
                    guard let self = self else { return }
                    do {
                        try self.handleError(error)
                        try handleResult(result, completion)
                    } catch {
                        let error = (error as? AppError) ?? AppError()
                        completion(.failure(error))
                    }
                }
            }
            .eraseToAnyPublisher()
        } catch {
            return Fail(error: AppError(error: error)).eraseToAnyPublisher()
        }
    }

    private func decodeResult<Model: Decodable>(_ result: HTTPSCallableResult?) throws -> Model {
        if let result = result?.data as? [String: Any] {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                return try JSONDecoder().decode(Model.self, from: jsonData)
            } catch {
                throw AppError(title: "Network Error", message: "Data decoding failed", error: error)
            }
        } else {
            throw AppError(title: "Network Error", message: "Data decoding failed")
        }
    }

    private func decodeResultArray<Model: Decodable>(_ result: HTTPSCallableResult?) throws -> [Model] {
        if let result = result?.data as? [Any] {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                return try JSONDecoder().decode([Model].self, from: jsonData)
            } catch {
                throw AppError(title: "Network Error", message: "Data decoding failed", error: error)
            }
        } else {
            throw AppError(title: "Network Error", message: "Data decoding failed")
        }
    }

    private func handleError(_ error: Error?) throws {
        if let error = error as NSError? {
            if error.domain == FunctionsErrorDomain {
                let message = error.localizedDescription
                throw AppError(message: message, error: error)
            } else {
                throw AppError(title: "Network Error", message: error.localizedDescription, error: error)
            }
        }
    }
}
