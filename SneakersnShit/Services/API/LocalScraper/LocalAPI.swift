//
//  LocalAPI.swift
//  CopDeck
//
//  Created by István Kreisz on 11/4/21.
//

import Combine
import UIKit

enum FetchMode: String {
    case forcedRefresh
    case cacheOnly
    case cacheOrRefresh
}

protocol LocalAPI {
    func reset()
    func getCalculatedPrices(for item: Item, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError>
}
