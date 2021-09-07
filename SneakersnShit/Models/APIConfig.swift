//
//  APIConfig.swift
//  CopDeck
//
//  Created by István Kreisz on 7/5/21.
//

import Foundation
import JavaScriptCore

struct APIConfig: Codable {
    let currency: Currency
    let isLoggingEnabled: Bool
    var proxies: [Int] = []
    let exchangeRates: ExchangeRates
    let feeCalculation: FeeCalculation

    struct FeeCalculation: Codable {
        let countryName: String
        let stockx: Stockx
        let goat: Goat
        let klekt: Klekt

        struct Goat: Codable {
            let commissionPercentage: Double
            let cashOutFee: Double
            let taxes: Double
        }

        struct Stockx: Codable {
            let sellerFee: Double
            let taxes: Double
        }

        struct Klekt: Codable {
            let taxes: Double
        }
    }
}
