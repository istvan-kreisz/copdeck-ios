//
//  MockFunctionsManager.swift
//  SneakersnShit
//
//  Created by István Kreisz on 2/14/21.
//

import Foundation

import Foundation
import Combine
import FirebaseFunctions

class MockFunctionsManager: FunctionsManager {
    func getMainFeedData(userId: String) -> AnyPublisher<MainState, AppError> {
        Empty().eraseToAnyPublisher()
    }

    func tradeStock(userId: String, stockId: String, amount: Int, type: TradeType) -> AnyPublisher<MainState, AppError> {
        Empty().eraseToAnyPublisher()
    }

    func getStockData(userId: String, stockId: String, type: StockQueryType) -> AnyPublisher<Stock, AppError> {
        Empty().eraseToAnyPublisher()
    }

    func getStocksHistory(userId: String) -> AnyPublisher<[Stock], AppError> {
        Empty().eraseToAnyPublisher()
    }

    func getStocksInCategory(userId: String, category: StockCategory) -> AnyPublisher<[Stock], AppError> {
        Empty().eraseToAnyPublisher()
    }

    func getUserData(userId: String) -> AnyPublisher<User, AppError> {
        Empty().eraseToAnyPublisher()
    }

    func changeUsername(userId: String, newName: String) -> AnyPublisher<User, AppError> {
        Empty().eraseToAnyPublisher()
    }

    func search(userId: String, searchTerm: String) -> AnyPublisher<[String], AppError> {
        Empty().eraseToAnyPublisher()
    }

    func getNews(userId: String) {}

    init() {}
}
