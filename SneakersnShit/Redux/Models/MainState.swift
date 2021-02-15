//
//  MainState.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation

// MARK: - Result
struct MainState: Codable, Equatable {
    var userId = ""
    var user: User?
    var userStocks: [Stock]?
    var trendingStocks: [Stock]?
    var selectedStock: Stock?
    var selectedUser: User?
    var selectedUserStocks: [Stock]?
    var selectedStocks: [Stock]?
    var searchResults: [String]?
    
    enum CodingKeys: String, CodingKey {
        case user, userStocks, trendingStocks
    }
}

// MARK: - User
struct User: Codable, Equatable {
    var name: String
    var starterCash: Int
    var cash: Double
    var transactions: [Transaction]
}

// MARK: - Transaction
struct Transaction: Codable, Equatable {
    var id: String
    var trades: [Trade]
}

// MARK: - Trade
struct Trade: Codable, Equatable {
    var time: String
    var amount: Int
}

// MARK: - Stock
struct Stock: Codable, Equatable, Identifiable {
    var id: String
    var price: Double
    var recentRecords: RecentRecords
    var soldAmount: Int?
    var stats: [Price]?
}

// MARK: - RecentRecords
struct RecentRecords: Codable, Equatable {
    var soldAmount: Int?
    var transactions: [Price]?
    var percentChange: Double?
    var price: [Price]?
}

// MARK: - Price
struct Price: Codable, Equatable {
    var time: String
    var value: Double
}
