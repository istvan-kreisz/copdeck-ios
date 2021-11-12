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
    var cookiesPublisher: AnyPublisher<[Cookie], Never> { get }
    var imageDownloadHeadersPublisher: AnyPublisher<[HeadersWithStoreId], Never> { get }

    func reset()
    func clearCookies()
    func refreshHeadersAndCookie()
    func search(searchTerm: String, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError>
    func getItemDetails(for item: Item, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError>
    func getCalculatedPrices(for item: Item, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError>
    func getPopularItems(settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError>
}
