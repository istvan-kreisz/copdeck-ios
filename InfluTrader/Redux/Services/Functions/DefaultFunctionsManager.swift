//
//  DefaultFunctionsManager.swift
//  InfluTrader
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Combine
import FirebaseFunctions

enum FunctionError {
    case decodingFailure
}

class DefaultFunctionsManager: FunctionsManager {
    private let functions = Functions.functions()

    init() {
        #if DEBUG
            functions.useEmulator(withHost: "http://istvans-macbook-pro-2.local", port: 5001)
        #endif
    }

    func getMainFeedData() -> AnyPublisher<MainState, AppError> {
        Future<MainState, AppError> { [weak self] publisher in
            self?.functions.httpsCallable("getMainFeedData").call(["userId": "wTHauqSNruQewLr4FfB6k0tVIAg2"]) { result, error in
                if let error = error as NSError? {
                    if error.domain == FunctionsErrorDomain {
//                        let code = FunctionsErrorCode(rawValue: error.code)
                        let message = error.localizedDescription
//                        let details = error.userInfo[FunctionsErrorDetailsKey]
                        publisher(.failure(AppError(message: message, error: error)))
                    } else {
                        publisher(.failure(AppError(title: "Network Error", message: error.localizedDescription, error: error)))
                    }
                } else {
                    if let result = result?.data as? [String: Any] {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                            let mainState = try JSONDecoder().decode(MainState.self, from: jsonData)
                            publisher(.success(mainState))
                        } catch {
                            publisher(.failure(AppError(title: "Network Error", message: "Data decoding failed", error: error)))
                        }
                    } else {
                        publisher(.failure(AppError(title: "Network Error", message: "Data decoding failed")))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func tradeStock(stockId: String, amount: Int, type: TradeType) -> AnyPublisher<Void, AppError> {
        Future<Void, AppError> { [weak self] publisher in
            let body: [String: Any] = [
                "userId": "wTHauqSNruQewLr4FfB6k0tVIAg2",
                "stockId": stockId,
                "amount": amount,
                "tradeType": type.rawValue
            ]

            self?.functions.httpsCallable("tradeStock").call(body) { result, error in
                if let error = error as NSError? {
                    if error.domain == FunctionsErrorDomain {
//                        let code = FunctionsErrorCode(rawValue: error.code)
                        let message = error.localizedDescription
//                        let details = error.userInfo[FunctionsErrorDetailsKey]
                        publisher(.failure(AppError(message: message, error: error)))
                    } else {
                        publisher(.failure(AppError(title: "Network Error", message: error.localizedDescription, error: error)))
                    }
                } else {
//                    if let result = result?.data as? [String: Any] {
//                        do {
//                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
//                            let mainState = try JSONDecoder().decode(MainState.self, from: jsonData)
                            publisher(.success(()))
//                        } catch {
//                            publisher(.failure(AppError(title: "Network Error", message: "Data decoding failed", error: error)))
//                        }
//                    } else {
//                        publisher(.failure(AppError(title: "Network Error", message: "Data decoding failed")))
//                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func getStockData() {}

    func getStocksHistory() {}

    func getStocksInCategory() {}

    func getUserData() {}

    func changeUsername() {}

    func getNews() {}

    func search() {}
}
