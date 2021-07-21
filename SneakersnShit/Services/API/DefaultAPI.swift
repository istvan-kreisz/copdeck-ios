//
//  DefaultAPI.swift
//  CopDeck
//
//  Created by István Kreisz on 7/8/21.
//

import Foundation
import Combine

class DefaultAPI: API {
    let backendAPI: API
    let localScraper: API

    init(backendAPI: API, localScraper: API) {
        self.backendAPI = backendAPI
        self.localScraper = localScraper
    }

    func getExchangeRates() -> AnyPublisher<ExchangeRates, AppError> {
        localScraper.getExchangeRates()
    }

    func search(searchTerm: String) -> AnyPublisher<[Item], AppError> {
        localScraper.search(searchTerm: searchTerm)
    }

    func getItemDetails(for item: Item) -> AnyPublisher<Item, AppError> {
        localScraper.getItemDetails(for: item)
    }
}
