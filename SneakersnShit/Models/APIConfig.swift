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
    let exchangeRates: ExchangeRates?
    let feeCalculation: CopDeckSettings.FeeCalculation
}
