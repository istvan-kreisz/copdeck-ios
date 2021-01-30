//
//  MainFeed.swift
//  InfluTrader
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation

struct MainState: Codable, Equatable {
    var user: User?
    private var userStocks: [String: Stock]?
    var trendingStocks: [Stock]?

    var userStocksArray: [OwnedStock] {
        let ownedStocks = (user?.transactions ?? [:])
            .map { stockId, transactions in (stockId, transactions.values.map { $0 as Int }.sum()) }
            .sorted(by: { $0.0 < $1.0 })
            .map { $0.1 }

        let stocksData = (userStocks ?? [:])
            .map { name, stock in stock.with(name: name) }
            .sorted(by: { $0.id < $1.id })

        return zip(ownedStocks, stocksData).map { amount, stock in
            OwnedStock(stock: stock, amount: amount)
        }
    }
}

struct OwnedStock: Identifiable {
    var id: String { stock.id }
    let stock: Stock
    let amount: Int
    var price: Double {
        (stock.price ?? 0) * Double(amount)
    }
}

struct User: Codable, Equatable {
    var starterCash: Int?
    var name: String?
    var cash: Double?
    var transactions: [String: [String: Int]]?
}

struct Stock: Codable, Equatable, Identifiable {
    var id: String { name ?? "" }
    var name: String?
    var price: Double?
    var soldAmount: Int?
    var recentRecords: RecentRecords? = .init()

    struct RecentRecords: Codable, Equatable {
        var percentChange: Int?
        var soldAmount: Int?
        var price: [String: Double]?
        var transactions: [String: Int]?
    }

    func with(name: String) -> Stock {
        var copy = self
        copy.name = name
        return copy
    }
}
