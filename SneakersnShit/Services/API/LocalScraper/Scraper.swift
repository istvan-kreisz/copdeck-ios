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
    private static let timeout = 15.0

    private var itemWithCalculatedPricesSubjects: [Double: PassthroughSubject<Item, AppError>] = [:]

    var id: (Double, String) {
        let val = Date().timeIntervalSince1970
        return (val, String(val))
    }

    private var native: JSNativeBridge!
    private lazy var interpreter: JavascriptInterpreter = {
        if DebugSettings.shared.isInDebugMode {
            JSBridgeConfiguration.add(logger: JSLogger())
        }
        let interpreter = JavascriptInterpreter()
        native = JSNativeBridge()
        native.delegate = self
        interpreter.jsContext.setObject(native, forKeyedSubscript: "native" as NSString)
        return interpreter
    }()

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
    
    func reset() {
        itemWithCalculatedPricesSubjects.values.forEach { $0.send(completion: .finished) }
        itemWithCalculatedPricesSubjects.removeAll()
    }
}

extension LocalScraper: LocalAPI {
    func getCalculatedPrices(for item: Item, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        guard let itemJSON = item.asJSON else {
            return Fail(outputType: Item.self, failure: AppError(title: "Error", message: "Invalid Item object", error: nil)).eraseToAnyPublisher()
        }

        let id = id
        interpreter.call(object: nil,
                         functionName: "scraper.api.calculatePrices",
                         arguments: [itemJSON, DefaultDataController.config(from: settings, exchangeRates: exchangeRates).asJSON!, id.1],
                         completion: { _ in })
        let itemWithCalculatedPricesSubject = PassthroughSubject<Item, AppError>()
        itemWithCalculatedPricesSubjects[id.0] = itemWithCalculatedPricesSubject

        return itemWithCalculatedPricesSubject
            .timeout(.seconds(Self.timeout), scheduler: DispatchQueue.main)
            .first()
            .eraseToAnyPublisher()
    }
}

extension LocalScraper: JSNativeBridgeDelegate {
    func setItemWithCalculatedPrices(_ item: WrappedResult<Item>) {
        guard let id = Double(item.requestId), let publisher = itemWithCalculatedPricesSubjects[id] else { return }
        publisher.send(item.res)
    }
    
    func setError(_ error: String, requestId: String) {
        guard let id = Double(requestId) else { return }
        itemWithCalculatedPricesSubjects[id]?.send(completion: .failure(.init(title: "Error", message: error, error: nil)))
    }
}
