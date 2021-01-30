//
//  MainFeed.swift
//  InfluTrader
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation

struct MainFeed: Codable {
    let user: User?
    let userStocks: [String: Stock]?
    let trendingStocks: [Stock]?
}

struct User: Codable {
    var starterCash: Int?
    var name: String?
    var cash: Double?
    var transactions: [String: [String: Int]]?
}

struct Stock: Codable {
    var price: Double?
    var soldAmount: Int?
    var recentRecords: RecentRecords? = .init()

    struct RecentRecords: Codable {
        var percentChange: Int?
        var soldAmount: Int?
        var price: [String: Double]?
        var transactions: [String: Int]?
    }
}
