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

    var cookiesPublisher: AnyPublisher<[Cookie], Never> {
        cookiesSubject.eraseToAnyPublisher()
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
        let feeCalculation = APIConfig.FeeCalculation(countryName: settings.feeCalculation.country.name,
                                                      stockx: .init(sellerLevel: (settings.feeCalculation.stockx?.sellerLevel.rawValue) ?? 1,
                                                                    taxes: (settings.feeCalculation.stockx?.taxes) ?? 0),
                                                      goat: .init(commissionPercentage: (settings.feeCalculation.goat?.commissionPercentage.rawValue) ?? 0,
                                                                  cashOutFee: (settings.feeCalculation.goat?.cashOutFee.rawValue) ?? 0.0,
                                                                  taxes: (settings.feeCalculation.goat?.taxes) ?? 0))
        var showLogs = false
        #if DEBUG
            showLogs = true && DebugSettings.shared.showScraperLogs
        #endif
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

extension LocalScraper: API {
    func getItemDetails(for item: Item?,
                        itemId: String,
                        forced: Bool,
                        settings: CopDeckSettings,
                        exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        if DebugSettings.shared.showScraperLogs {
            print("scraping...")
        }
        if let item = item {
            return getItemDetails(for: item, settings: settings, exchangeRates: exchangeRates)
                .handleEvents(receiveOutput: { [weak self] _ in self?.getCookies() }).eraseToAnyPublisher()
        } else {
            return getItemDetails(forItemWithId: itemId, settings: settings, exchangeRates: exchangeRates)
                .handleEvents(receiveOutput: { [weak self] _ in self?.getCookies() }).eraseToAnyPublisher()
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

    private func getItemDetails(for item: Item, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        itemSubject.send(completion: .finished)
        itemSubject = PassthroughSubject<Item, AppError>()
        guard let itemJSON = item.asJSON else {
            return Fail(outputType: Item.self, failure: AppError(title: "Error", message: "Invalid Item object", error: nil)).eraseToAnyPublisher()
        }

        interpreter.call(object: nil,
                         functionName: "scraper.api.getItemPrices",
                         arguments: [itemJSON, config(from: settings, exchangeRates: exchangeRates)],
                         completion: { _ in })
        return itemSubject.first().eraseToAnyPublisher()
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
            .handleEvents(receiveOutput: { [weak self] _ in self?.getCookies() })
            .eraseToAnyPublisher()
    }

    func getCalculatedPrices(for item: Item, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        itemWithCalculatedPricesSubject.send(completion: .finished)
        itemWithCalculatedPricesSubject = PassthroughSubject<Item, AppError>()
        guard let itemJSON = item.asJSON else {
            return Fail(outputType: Item.self, failure: AppError(title: "Error", message: "Invalid Item object", error: nil)).eraseToAnyPublisher()
        }

        interpreter.call(object: nil,
                         functionName: "scraper.api.calculatePrices",
                         arguments: [itemJSON, config(from: settings, exchangeRates: exchangeRates)],
                         completion: { _ in })
        return itemWithCalculatedPricesSubject.first().eraseToAnyPublisher()
    }

    func getCookies() {
        interpreter.call(object: nil,
                         functionName: "scraper.api.getCookies",
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
}
