//
//  FunctionsManager.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Combine

protocol FunctionsManager {
    func tradeStock(userId: String, stockId: String, amount: Int, type: TradeType) -> AnyPublisher<MainState, AppError>
    func getStockData(userId: String, stockId: String, type: StockQueryType) -> AnyPublisher<Stock, AppError>
    func getMainFeedData(userId: String) -> AnyPublisher<MainState, AppError>
    func getStocksHistory(userId: String) -> AnyPublisher<[Stock], AppError>
    func getStocksInCategory(userId: String, category: StockCategory) -> AnyPublisher<[Stock], AppError>
    func getUserData(userId: String) -> AnyPublisher<User, AppError>
    func changeUsername(userId: String, newName: String) -> AnyPublisher<User, AppError>
    func getNews(userId: String)
    func search(userId: String, searchTerm: String) -> AnyPublisher<[String], AppError>
}
