//
//  Player.swift
//  InfluTrader
//
//  Created by István Kreisz on 12/14/20.
//

import Foundation

struct Player {
    struct Asset {
    }
    let bankHistory: [Double]
    let percentile: Int
    let portfolio: [(Influencer, Int)]
}
