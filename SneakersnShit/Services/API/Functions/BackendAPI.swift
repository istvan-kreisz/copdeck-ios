//
//  BackendAPI.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Combine
import FirebaseFunctions

class BackendAPI: API {
    func getExchangeRates() -> AnyPublisher<ExchangeRates, AppError> {
        PassthroughSubject<ExchangeRates, AppError>().eraseToAnyPublisher()
    }

    // todo: refactor shit

    func search(searchTerm: String) -> AnyPublisher<[Item], AppError> {
        struct Params: Encodable {
            let searchTerm: String
        }
        return callFirebaseFunctionArray(functionName: "search", model: Params(searchTerm: searchTerm))
    }

    func getItemDetails(for item: Item) -> AnyPublisher<Item, AppError> {
        struct Params: Encodable {
            let item: Item
        }
        return callFirebaseFunction(functionName: "getItemDetails", model: Params(item: item))
    }

//    func addToInventory(userId: String, inventoryItem: InventoryItem) -> AnyPublisher<InventoryItem, AppError> {
//        struct Params: Encodable {
//            let userId: String
//            let inventoryItem: InventoryItem
//        }
//        return callFirebaseFunction(functionName: "addInventoryItem", model: Params(userId: userId, inventoryItem: inventoryItem))
//    }
//
//    func removeFromInventory(userId: String, inventoryItem: InventoryItem) -> AnyPublisher<Void, AppError> {
//        struct Params: Encodable {
//            let userId: String
//            let inventoryItemId: String
//        }
//        return callFirebaseFunction(functionName: "removeInventoryItem", model: Params(userId: userId, inventoryItemId: inventoryItem.id))
//    }
//
//    func getInventoryItems(userId: String) -> AnyPublisher<[InventoryItem], AppError> {
//        struct Params: Encodable {
//            let userId: String
//        }
//        return callFirebaseFunctionArray(functionName: "getInventoryItems", model: Params(userId: userId))
//    }

    private let functions = Functions.functions(region: "europe-west1")

    init() {
        #if DEBUG
            if DebugSettings.shared.useFunctionsEmulator {
                functions.useFunctionsEmulator(origin: "http://istvans-macbook-pro-2.local:5001")
            }
        #endif
    }

    private func callFirebaseFunction(functionName: String, model: Encodable) -> AnyPublisher<Void, AppError> {
        do {
            let parameters = try model.asDictionary()
            return Future<Void, AppError> { [weak self] completion in
                self?.functions.httpsCallable(functionName).call(parameters) { [weak self] result, error in
                    guard let self = self else { return }
                    do {
                        try self.handleError(error)
                        completion(.success(()))
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

    private func callFirebaseFunction<Model: Decodable>(functionName: String, model: Encodable) -> AnyPublisher<Model, AppError> {
        do {
            let parameters = try model.asDictionary()
            return Future<Model, AppError> { [weak self] completion in
                self?.functions.httpsCallable(functionName).call(parameters) { [weak self] result, error in
                    guard let self = self else { return }
                    do {
                        try self.handleError(error)
                        let result: Model = try self.decodeResult(result)
                        completion(.success(result))
                    } catch {
                        let error = (error as? AppError) ?? AppError()
                        print(error)
                        completion(.failure(error))
                    }
                }
            }
            .eraseToAnyPublisher()
        } catch {
            return Fail(error: AppError(error: error)).eraseToAnyPublisher()
        }
    }

    private func callFirebaseFunctionArray<Model: Decodable>(functionName: String, model: Encodable) -> AnyPublisher<[Model], AppError> {
        do {
            let parameters = try model.asDictionary()
            return Future<[Model], AppError> { [weak self] completion in
                self?.functions.httpsCallable(functionName).call(parameters) { [weak self] result, error in
                    guard let self = self else { return }
                    do {
                        try self.handleError(error)
                        let result: [Model] = try self.decodeResultArray(result)
                        completion(.success(result))
                    } catch {
                        let error = (error as? AppError) ?? AppError()
                        print(error)
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
