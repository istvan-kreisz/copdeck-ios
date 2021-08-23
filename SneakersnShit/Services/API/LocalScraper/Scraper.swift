//
//  LocalScraper.swift
//  CopDeck
//
//  Created by István Kreisz on 6/26/21.
//

import JavaScriptCore
import OasisJSBridge
import Combine

class LocalScraper {
    private var exchangeRatesSubject = PassthroughSubject<ExchangeRates, AppError>()
    private var itemsSubject = PassthroughSubject<[Item], AppError>()
    private var itemSubject = PassthroughSubject<Item, AppError>()
    private var itemWithCalculatedPricesSubject = PassthroughSubject<Item, AppError>()
    private let cookiesSubject = PassthroughSubject<[Cookie], Never>()
    private let imageDownloadHeaders = PassthroughSubject<[HeadersWithStoreId], Never>()
    private var popularItemsSubject = PassthroughSubject<[Item], AppError>()

    var cookiesPublisher: AnyPublisher<[Cookie], Never> {
        cookiesSubject.eraseToAnyPublisher()
    }

    var imageDownloadHeadersPublisher: AnyPublisher<[HeadersWithStoreId], Never> {
        imageDownloadHeaders.eraseToAnyPublisher()
    }

    private var native: JSNativeBridge!
    private lazy var interpreter: JavascriptInterpreter = {
        JSBridgeConfiguration.add(logger: JSLogger())
        let interpreter = JavascriptInterpreter()
        native = JSNativeBridge()
        native.delegate = self
        interpreter.jsContext.setObject(native, forKeyedSubscript: "native" as NSString)
        return interpreter
    }()

    func config(from settings: CopDeckSettings, exchangeRates: ExchangeRates) -> Any {
        let stockXLevelIsAtLeast4 = settings.feeCalculation.stockx?.sellerLevel == .level4 || settings.feeCalculation.stockx?.sellerLevel == .level5
        let feeCalculation = APIConfig.FeeCalculation(countryName: settings.feeCalculation.country.name,
                                                      stockx: .init(sellerLevel: (settings.feeCalculation.stockx?.sellerLevel.rawValue) ?? 1,
                                                                    taxes: (settings.feeCalculation.stockx?.taxes) ?? 0,
                                                                    successfulShipBonus: (settings.feeCalculation.stockx?.successfulShipBonus ?? false) &&
                                                                        stockXLevelIsAtLeast4,
                                                                    quickShipBonus: (settings.feeCalculation.stockx?.quickShipBonus ?? false) &&
                                                                        stockXLevelIsAtLeast4),
                                                      goat: .init(commissionPercentage: (settings.feeCalculation.goat?.commissionPercentage.rawValue) ?? 0,
                                                                  cashOutFee: (settings.feeCalculation.goat?.cashOutFee == true) ? 0.029 : 0,
                                                                  taxes: (settings.feeCalculation.goat?.taxes) ?? 0),
                                                      klekt: .init(taxes: (settings.feeCalculation.klekt?.taxes) ?? 0))
        var showLogs = false
        if DebugSettings.shared.isInDebugMode {
            showLogs = true && DebugSettings.shared.showScraperLogs
        }
        return APIConfig(currency: settings.currency,
                         isLoggingEnabled: showLogs,
                         exchangeRates: exchangeRates,
                         feeCalculation: feeCalculation).asJSON!
    }

    init() {
        guard let scraper = Bundle.main.url(forResource: "scraper.bundle", withExtension: "js"),
              let jsCode = try? String.init(contentsOf: scraper)
        else { return }
        interpreter.evaluateString(js: jsCode) { _, error in
            if let error = error {
                DispatchQueue.main.async {
                    print(error)
                }
            } else {
                //
            }
        }
    }
}

extension LocalScraper: LocalAPI {
    func getItemDetails(for item: Item?,
                        itemId: String,
                        fetchMode: FetchMode,
                        settings: CopDeckSettings,
                        exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        if DebugSettings.shared.showScraperLogs {
            print("scraping...")
        }
        if let item = item {
            return getItemDetails(for: item, settings: settings, exchangeRates: exchangeRates)
                .handleEvents(receiveOutput: { [weak self] _ in self?.refreshHeadersAndCookie() }).eraseToAnyPublisher()
        } else {
            return getItemDetails(forItemWithId: itemId, settings: settings, exchangeRates: exchangeRates)
                .handleEvents(receiveOutput: { [weak self] _ in self?.refreshHeadersAndCookie() }).eraseToAnyPublisher()
        }
    }

    private func getItemDetails(forItemWithId id: String, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        search(searchTerm: id, settings: settings, exchangeRates: exchangeRates)
            .compactMap { items in items.first(where: { $0.id == id }) }
            .flatMap { [weak self] item -> AnyPublisher<Item, AppError> in
                guard let self = self else {
                    return Fail<Item, AppError>(error: AppError.unknown).eraseToAnyPublisher()
                }
                return self.getItemDetails(for: item, settings: settings, exchangeRates: exchangeRates).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    #warning("refactor publishers")
    private func getItemDetails(for item: Item, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        guard let itemJSON = item.asJSON else {
            return Fail(outputType: Item.self, failure: AppError(title: "Error", message: "Invalid Item object", error: nil)).eraseToAnyPublisher()
        }

        interpreter.call(object: nil,
                         functionName: "scraper.api.getItemPrices",
                         arguments: [itemJSON, config(from: settings, exchangeRates: exchangeRates)],
                         completion: { _ in })
        return itemSubject
            .timeout(.seconds(15), scheduler: DispatchQueue.main)
            .first { $0.id == item.id }
            .eraseToAnyPublisher()
    }

    func getExchangeRates(settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<ExchangeRates, AppError> {
        exchangeRatesSubject.send(completion: .finished)
        exchangeRatesSubject = PassthroughSubject<ExchangeRates, AppError>()
        interpreter.call(object: nil,
                         functionName: "scraper.api.getExchangeRates",
                         arguments: [config(from: settings, exchangeRates: exchangeRates)],
                         completion: { _ in })
        return exchangeRatesSubject.first().eraseToAnyPublisher()
    }

    func search(searchTerm: String, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError> {
        itemsSubject.send(completion: .finished)
        itemsSubject = PassthroughSubject<[Item], AppError>()

        interpreter.call(object: nil,
                         functionName: "scraper.api.searchItems",
                         arguments: [searchTerm, config(from: settings, exchangeRates: exchangeRates)],
                         completion: { _ in })
        return itemsSubject
            .first()
            .handleEvents(receiveOutput: { [weak self] _ in self?.refreshHeadersAndCookie() })
            .eraseToAnyPublisher()
    }

    func getCalculatedPrices(for item: Item, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        guard let itemJSON = item.asJSON else {
            return Fail(outputType: Item.self, failure: AppError(title: "Error", message: "Invalid Item object", error: nil)).eraseToAnyPublisher()
        }

        interpreter.call(object: nil,
                         functionName: "scraper.api.calculatePrices",
                         arguments: [itemJSON, config(from: settings, exchangeRates: exchangeRates)],
                         completion: { _ in })
        return itemWithCalculatedPricesSubject
            .timeout(.seconds(15), scheduler: DispatchQueue.main)
            .first { $0.id == item.id }
            .eraseToAnyPublisher()
    }

    func getPopularItems(settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError> {
        popularItemsSubject.send(completion: .finished)
        popularItemsSubject = PassthroughSubject<[Item], AppError>()
        interpreter.call(object: nil,
                         functionName: "scraper.api.getPopularItems",
                         arguments: [config(from: settings, exchangeRates: exchangeRates)],
                         completion: { _ in })

        return popularItemsSubject.first().eraseToAnyPublisher()
    }

    private func refreshHeadersAndCookie() {
        getCookies()
        getImageDownloadHeaders()
    }

    private func getCookies() {
        interpreter.call(object: nil,
                         functionName: "scraper.api.getCookies",
                         arguments: [],
                         completion: { _ in })
    }

    private func getImageDownloadHeaders() {
        interpreter.call(object: nil,
                         functionName: "scraper.api.getImageDownloadHeaders",
                         arguments: [],
                         completion: { _ in })
    }
}

extension LocalScraper: JSNativeBridgeDelegate {
    func setExchangeRates(_ exchangeRates: ExchangeRates) {
        exchangeRatesSubject.send(exchangeRates)
    }

    func setItems(_ items: [Item]) {
        itemsSubject.send(items)
    }

    func setItem(_ item: Item) {
        itemSubject.send(item)
    }

    func setItemWithCalculatedPrices(_ item: Item) {
        itemWithCalculatedPricesSubject.send(item)
    }

    func setCookies(_ cookies: [Cookie]) {
        if !cookies.isEmpty {
            cookiesSubject.send(cookies)
        }
    }

    func setImageDownloadHeaders(_ headers: [HeadersWithStoreId]) {
        if !headers.isEmpty {
            imageDownloadHeaders.send(headers)
        }
    }

    func setPopularItems(_ items: [Item]) {
        popularItemsSubject.send(items)
    }
}
