//
//  DefaultFunctionsManager.swift
//  InfluTrader
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Combine
import FirebaseFunctions

class DefaultFunctionsManager: FunctionsManager {
    func tradeStock(userId: String, stockId: String, amount: Int, type: TradeType) -> AnyPublisher<MainState, AppError> {
        callFirebaseFunction(functionName: "getMainFeedData",
                             userId: userId,
                             parameters: ["amount": amount, "tradeType": type.rawValue, "stockId": stockId])
    }

    func getStockData(userId: String, stockId: String, type: StockQueryType) -> AnyPublisher<Stock, AppError> {
        callFirebaseFunction(functionName: "getMainFeedData", userId: userId, parameters: ["stockId": stockId, "queryType": type.rawValue])
    }

    func getStocksHistory(userId: String) -> AnyPublisher<[Stock], AppError> {
        callFirebaseFunction(functionName: "getMainFeedData", userId: userId)
    }

    func getStocksInCategory(userId: String, category: StockCategory) -> AnyPublisher<[Stock], AppError> {
        callFirebaseFunction(functionName: "getMainFeedData", userId: userId, parameters: ["category": category.rawValue])
    }

    func getUserData(userId: String) -> AnyPublisher<User, AppError> {
        callFirebaseFunction(functionName: "getMainFeedData", userId: userId)
    }

    func changeUsername(userId: String, newName: String) -> AnyPublisher<User, AppError> {
        callFirebaseFunction(functionName: "getMainFeedData", userId: userId, parameters: ["username": newName])
    }

    func search(userId: String, searchTerm: String) -> AnyPublisher<[String], AppError> {
        callFirebaseFunction(functionName: "getMainFeedData", userId: userId, parameters: ["searchTerm": searchTerm])
    }

    func getNews(userId: String) {}

    private let functions = Functions.functions()

    init() {
        #if DEBUG
            functions.useEmulator(withHost: "http://istvans-macbook-pro-2.local", port: 5001)
        #endif
    }

    func getMainFeedData(userId: String) -> AnyPublisher<MainState, AppError> {
        callFirebaseFunction(functionName: "getMainFeedData", userId: userId)
    }

    private func callFirebaseFunction(functionName: String,
                                      userId: String,
                                      parameters: [String: Any] = [:]) -> AnyPublisher<Void, AppError> {
        Future<Void, AppError> { [weak self] completion in
            self?.functions.httpsCallable(functionName).call(parameters.merging(["userId": userId]) { $1 }) { [weak self] result, error in
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
    }

    private func callFirebaseFunction<Model: Decodable>(functionName: String,
                                                        userId: String,
                                                        parameters: [String: Any] = [:]) -> AnyPublisher<Model, AppError> {
        Future<Model, AppError> { [weak self] completion in
            self?.functions.httpsCallable(functionName).call(parameters.merging(["userId": userId]) { $1 }) { [weak self] result, error in
                guard let self = self else { return }
                do {
                    try self.handleError(error)
                    let result: Model = try self.decodeResult(result)
                    completion(.success(result))
                } catch {
                    let error = (error as? AppError) ?? AppError()
                    completion(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
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
