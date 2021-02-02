//
//  MainFeed.swift
//  InfluTrader
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation

// MARK: - Result
struct MainState: Codable, Equatable {
    var user: User?
    var userStocks: [Stock]?
    var trendingStocks: [Stock]?
}

// MARK: - User
struct User: Codable, Equatable {
    var name: String?
    var starterCash: Int?
    var cash: Double?
    var transactions: [Transaction]?
}

// MARK: - Transaction
struct Transaction: Codable, Equatable {
    var id: String?
    var trades: [Trade]?
}

// MARK: - Trade
struct Trade: Codable, Equatable {
    var time: String?
    var amount: Int?
}

// MARK: - UserStock
struct Stock: Codable, Equatable {
    var id: String?
    var price: Double?
    var recentRecords: RecentRecords?
    var soldAmount: Int?
    var stats: [Price]?
}

// MARK: - UserStockRecentRecords
struct RecentRecords: Codable, Equatable {
    var soldAmount: Int?
    var transactions: [Price]?
    var percentChange: Double?
    var price: [Price]?
}

// MARK: - Price
struct Price: Codable, Equatable {
    var time: String
    var vale: Double
}
