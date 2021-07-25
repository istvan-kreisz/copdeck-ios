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
        let feeCalculation = APIConfig.FeeCalculation(countryName: "",
                                                      stockx: .init(sellerLevel: (settings.feeCalculation.stockx?.sellerLevel.rawValue) ?? 1,
                                                                    taxes: (settings.feeCalculation.stockx?.taxes) ?? 0),
                                                      goat: .init(commissionPercentage: (settings.feeCalculation.goat?.commissionPercentage.rawValue) ?? 0,
                                                                  cashOutFee: (settings.feeCalculation.goat?.cashOutFee.rawValue) ?? 0.0,
                                                                  taxes: (settings.feeCalculation.goat?.taxes) ?? 0))
        return APIConfig(currency: settings.currency,
                         isLoggingEnabled: true,
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
    func getItemDetails(for item: Item?, itemId: String, forced: Bool, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        if let item = item {
            return getItemDetails(for: item, settings: settings, exchangeRates: exchangeRates)
        } else {
            return getItemDetails(forItemWithId: itemId, settings: settings, exchangeRates: exchangeRates)
        }
    }

    private func getItemDetails(forItemWithId id: String, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        search(searchTerm: id, settings: settings, exchangeRates: exchangeRates)
            .compactMap { items in items.first(where: { $0.id == id }) }
            .eraseToAnyPublisher()
    }

    private func getItemDetails(for item: Item, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        itemSubject.send(completion: .finished)
        itemSubject = PassthroughSubject<Item, AppError>()
        guard let itemJSON = item.asJSON else {
            return Fail(outputType: Item.self, failure: AppError(title: "Error", message: "Invalid Item object", error: nil)).eraseToAnyPublisher()
        }

        interpreter.call(object: nil, functionName: "scraper.api.getItemPrices", arguments: [itemJSON, config(from: settings, exchangeRates: exchangeRates)],
                         completion: { result in })
        return itemSubject.first().eraseToAnyPublisher()
    }

    func getExchangeRates(settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<ExchangeRates, AppError> {
        exchangeRatesSubject.send(completion: .finished)
        exchangeRatesSubject = PassthroughSubject<ExchangeRates, AppError>()
        interpreter.call(object: nil, functionName: "scraper.api.getExchangeRates", arguments: [config(from: settings, exchangeRates: exchangeRates)],
                         completion: { result in })

        return exchangeRatesSubject.first().eraseToAnyPublisher()
    }

    func search(searchTerm: String, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError> {
        itemsSubject.send(completion: .finished)
        itemsSubject = PassthroughSubject<[Item], AppError>()

        interpreter.call(object: nil, functionName: "scraper.api.searchItems", arguments: [searchTerm, config(from: settings, exchangeRates: exchangeRates)],
                         completion: { result in })
        return itemsSubject.first().eraseToAnyPublisher()
    }
}

extension LocalScraper: JSNativeBridgeDelegate {
    func setExchangeRates(_ exchangeRates: ExchangeRates) {
        exchangeRatesSubject.send(exchangeRates)
    }

    func setItems(_ items: [Item]) {
        print("got em")
        itemsSubject.send(items)
    }

    func setItem(_ item: Item) {
        itemSubject.send(item)
    }
}
