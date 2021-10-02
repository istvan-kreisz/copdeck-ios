//
//  MonthlyStatistics.swift
//  CopDeck
//
//  Created by István Kreisz on 10/2/21.
//

import Foundation

struct MonthlyStatistics {
    let year: Int
    let month: Int
    var purchasPrices: [Double]
    var soldPrices: [Double]
    
    var purchasedCount: Int { purchasPrices.count }
    var soldCount: Int { soldPrices.count }
    var revenue: Double { soldPrices.sum() }
    var cost: Double { purchasPrices.sum() }
    var profit: Double { revenue - cost }
}
