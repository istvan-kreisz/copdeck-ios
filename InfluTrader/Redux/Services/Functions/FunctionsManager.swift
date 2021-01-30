//
//  FunctionsManager.swift
//  InfluTrader
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Combine

protocol FunctionsManager {
    func tradeStock()
    func getStockData()
    func getMainFeedData() -> AnyPublisher<MainState, AppError>
    func getStocksHistory()
    func getStocksInCategory()
    func getUserData()
    func changeUsername()
    func getNews()
    func search()
}
