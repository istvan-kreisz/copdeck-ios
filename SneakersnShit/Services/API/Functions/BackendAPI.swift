//
//  BackendAPI.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Combine
import FirebaseFunctions

class BackendAPI: API {
    func getItemDetails(for item: Item?, itemId: String, forced: Bool, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        if let item = item {
            return getItemDetails(for: item, settings: settings, exchangeRates: exchangeRates)
        } else {
            return getItemDetails(forItemWithId: itemId, settings: settings, exchangeRates: exchangeRates)
        }
    }

    private func getItemDetails(forItemWithId id: String, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        search(searchTerm: id, settings: settings, exchangeRates: exchangeRates)
            .compactMap { items in items.first(where: { $0.id == id }) }
            .eraseToAnyPublisher()
    }

    func getExchangeRates(settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<ExchangeRates, AppError> {
        PassthroughSubject<ExchangeRates, AppError>().eraseToAnyPublisher()
    }

    func search(searchTerm: String, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError> {
        struct Params: Encodable {
            let searchTerm: String
        }
        return callFirebaseFunctionArray(functionName: "search", model: Params(searchTerm: searchTerm))
    }

    private func getItemDetails(for item: Item, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        struct Params: Encodable {
            let item: Item
        }
        return callFirebaseFunction(functionName: "getItemDetails", model: Params(item: item))
    }

    func getCalculatedPrices(for item: Item, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        PassthroughSubject<Item, AppError>().eraseToAnyPublisher()
    }

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
