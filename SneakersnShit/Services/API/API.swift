//
//  API.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Combine

protocol API {
    var cookiesPublisher: AnyPublisher<[Cookie], Never> { get }
    var imageDownloadHeadersPublisher: AnyPublisher<[HeadersWithStoreId], Never> { get }

    func getExchangeRates(settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<ExchangeRates, AppError>
    func search(searchTerm: String, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError>
    func getItemDetails(for item: Item?, itemId: String, forced: Bool, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError>
    func getCalculatedPrices(for item: Item, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError>
}
