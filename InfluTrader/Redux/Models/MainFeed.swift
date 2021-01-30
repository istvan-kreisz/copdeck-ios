//
//  MainFeed.swift
//  InfluTrader
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation

struct MainState: Codable, Equatable {
    var user: User?
    var userStocks: [String: Stock]?
    var trendingStocks: [Stock]?
}

struct User: Codable, Equatable {
    var starterCash: Int?
    var name: String?
    var cash: Double?
    var transactions: [String: [String: Int]]?
}

struct Stock: Codable, Equatable {
    var price: Double?
    var soldAmount: Int?
    var recentRecords: RecentRecords? = .init()

    struct RecentRecords: Codable, Equatable {
        var percentChange: Int?
        var soldAmount: Int?
        var price: [String: Double]?
        var transactions: [String: Int]?
    }
}
