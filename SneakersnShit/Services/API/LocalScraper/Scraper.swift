//
//  LocalScraper.swift
//  SneakersnShit
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

    let apiConfig = APIConfig(currency: .init(code: .gbp, symbol: .gbp),
                              isLoggingEnabled: true,
                              exchangeRates: .init(usd: 1.2125, gbp: 0.8571, chf: 1.0883, nok: 10.0828),
                              feeCalculation: .init(countryName: "Austria",
                                                    stockx: .init(sellerLevel: 1, taxes: 0),
                                                    goat: .init(commissionPercentage: 15, cashOutFee: 2.9, taxes: 0)))

    lazy var config = apiConfig.asJSON!

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
    func getExchangeRates() -> AnyPublisher<ExchangeRates, AppError> {
        exchangeRatesSubject.send(completion: .finished)
        exchangeRatesSubject = PassthroughSubject<ExchangeRates, AppError>()
        interpreter.call(object: nil, functionName: "scraper.api.getExchangeRates", arguments: [config], completion: { result in })

        return exchangeRatesSubject.first().eraseToAnyPublisher()
    }

    func search(searchTerm: String) -> AnyPublisher<[Item], AppError> {
        itemsSubject.send(completion: .finished)
        itemsSubject = PassthroughSubject<[Item], AppError>()

        interpreter.call(object: nil, functionName: "scraper.api.searchItems", arguments: [searchTerm, config], completion: { result in })
        return itemsSubject.first().eraseToAnyPublisher()
    }

    func getItemDetails(for item: Item) -> AnyPublisher<Item, AppError> {
        itemSubject.send(completion: .finished)
        itemSubject = PassthroughSubject<Item, AppError>()
        guard let itemJSON = item.asJSON else {
            return Fail(outputType: Item.self, failure: AppError(title: "Error", message: "Invalid Item object", error: nil)).eraseToAnyPublisher()
        }

        interpreter.call(object: nil, functionName: "scraper.api.getItemPrices", arguments: [itemJSON, config], completion: { result in })
        return itemSubject.first().eraseToAnyPublisher()
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
}
