//
//  APIConfig.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/5/21.
//

import Foundation
import JavaScriptCore

struct APIConfig: Codable {
    let currency: SCurrency
    let isLoggingEnabled: Bool
//    var proxies: [Int] = []
    let exchangeRates: [String: Double]
    let feeCalculation: FeeCalculation

    struct FeeCalculation: Codable {
        let countryName: String
        let stockx: Stockx
        let goat: Goat

        struct Goat: Codable {
            let commissionPercentage: Double
            let cashOutFee: Double
            let taxes: Int
        }

        struct Stockx: Codable {
            let sellerLevel: Int
            let taxes: Int
        }
    }
}

struct SCurrency: Codable {
    let code: String
    let symbol: String
}
