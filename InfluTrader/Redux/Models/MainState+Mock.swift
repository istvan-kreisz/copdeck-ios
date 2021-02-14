//
//  MainState+Mock.swift
//  InfluTrader
//
//  Created by István Kreisz on 2/14/21.
//

import Foundation

extension MainState {
    private static var charliStock: Stock = .init(id: "charlidamelio",
                                                  price: 100,
                                                  recentRecords: .init(soldAmount: 7,
                                                                       transactions: [.init(time: "3", value: 3), .init(time: "4", value: 6)],
                                                                       percentChange: 12,
                                                                       price: [.init(time: "1", value: 4), .init(time: "2", value: 8)]),
                                                  soldAmount: 7,
                                                  stats: [])

    private static var bellaStock: Stock = .init(id: "bellapoarch",
                                                 price: 100,
                                                 recentRecords: .init(soldAmount: 7,
                                                                      transactions: [.init(time: "1", value: 2), .init(time: "2", value: 5)],
                                                                      percentChange: 10,
                                                                      price: [.init(time: "1", value: 1), .init(time: "2", value: 3)]),
                                                 soldAmount: 7,
                                                 stats: [])

    static var mockMainState: MainState = .init(userId: "Kd24f2VebTWpTYYqAkSeHZwWhB83",
                                                user: .init(name: "biggus dickus",
                                                            starterCash: 1000,
                                                            cash: 900,
                                                            transactions: [.init(id: "bellapoarch",
                                                                                 trades: [.init(time: "1", amount: 2), .init(time: "2", amount: 5)])]),
                                                userStocks: [bellaStock],
                                                trendingStocks: [bellaStock, charliStock],
                                                selectedStock: nil,
                                                selectedUser: nil,
                                                selectedUserStocks: [],
                                                selectedStocks: [],
                                                searchResults: nil)
}
