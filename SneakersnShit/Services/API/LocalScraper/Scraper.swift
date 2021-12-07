//
//  LocalScraper.swift
//  CopDeck
//
//  Created by István Kreisz on 6/26/21.
//

import JavaScriptCore
import OasisJSBridge
import Combine

#warning("fix cookies not getting cleared when resetting")
class LocalScraper {
    private static let timeout = 15.0

    private var scraperConfigRaw: Any?
    private let nullArray: [Int] = []
    private var scraperConfigArg: Any {
        scraperConfigRaw ?? nullArray.asJSON!
    }
    private let scraperConfigSubject = CurrentValueSubject<[ScraperConfig], Never>([])
    private let imageDownloadHeadersSubject = PassthroughSubject<[HeadersWithStoreId], Never>()

    private var exchangeRatesSubjects: [Double: PassthroughSubject<ExchangeRates, AppError>] = [:]
    private var itemsSubjects: [Double: PassthroughSubject<[Item], AppError>] = [:]
    private var itemSubjects: [Double: PassthroughSubject<Item, AppError>] = [:]
    private var itemWithCalculatedPricesSubjects: [Double: PassthroughSubject<Item, AppError>] = [:]
    private var popularItemsSubjects: [Double: PassthroughSubject<[Item], AppError>] = [:]

    var scraperConfigPublisher: AnyPublisher<[ScraperConfig], Never> {
        scraperConfigSubject.eraseToAnyPublisher()
    }

    var imageDownloadHeadersPublisher: AnyPublisher<[HeadersWithStoreId], Never> {
        imageDownloadHeadersSubject.eraseToAnyPublisher()
    }

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

    private func isOlderThan(date: Double, minutes: Double) -> Bool {
        (Date().timeIntervalSince1970 - date) / 60 > minutes
    }

    private func clearOldPublishers() {
        exchangeRatesSubjects.forEach { entry in
            if isOlderThan(date: entry.key, minutes: Self.timeout) {
                exchangeRatesSubjects[entry.key] = nil
            }
        }
        itemsSubjects.forEach { entry in
            if isOlderThan(date: entry.key, minutes: Self.timeout) {
                itemsSubjects[entry.key] = nil
            }
        }
        itemSubjects.forEach { entry in
            if isOlderThan(date: entry.key, minutes: Self.timeout) {
                itemSubjects[entry.key] = nil
            }
        }
        itemWithCalculatedPricesSubjects.forEach { entry in
            if isOlderThan(date: entry.key, minutes: Self.timeout) {
                itemWithCalculatedPricesSubjects[entry.key] = nil
            }
        }
        popularItemsSubjects.forEach { entry in
            if isOlderThan(date: entry.key, minutes: Self.timeout) {
                popularItemsSubjects[entry.key] = nil
            }
        }
    }

    init() {
        guard let scraper = Bundle.main.url(forResource: "scraper.bundle", withExtension: "js"),
              let jsCode = try? String.init(contentsOf: scraper)
        else { return }
        Timer.scheduledTimer(withTimeInterval: Self.timeout + 1, repeats: true) { [weak self] _ in
            self?.clearOldPublishers()
        }
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
        exchangeRatesSubjects.values.forEach { $0.send(completion: .finished) }
        itemsSubjects.values.forEach { $0.send(completion: .finished) }
        itemSubjects.values.forEach { $0.send(completion: .finished) }
        itemWithCalculatedPricesSubjects.values.forEach { $0.send(completion: .finished) }
        popularItemsSubjects.values.forEach { $0.send(completion: .finished) }

        exchangeRatesSubjects.removeAll()
        itemsSubjects.removeAll()
        itemSubjects.removeAll()
        itemWithCalculatedPricesSubjects.removeAll()
        popularItemsSubjects.removeAll()
    }
    
    func clearConfigs() {
        scraperConfigSubject.send([])
    }
}

extension LocalScraper: LocalAPI {
    func getItemDetails(for item: Item, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<Item, AppError> {
        guard let itemJSON = item.asJSON else {
            return Fail(outputType: Item.self, failure: AppError(title: "Error", message: "Invalid Item object", error: nil)).eraseToAnyPublisher()
        }

        let id = id
        interpreter.call(object: nil,
                         functionName: "scraper.api.getItemPrices",
                         arguments: [itemJSON, DefaultDataController.config(from: settings, exchangeRates: exchangeRates).asJSON!, id.1, scraperConfigArg],
                         completion: { _ in })
        let itemSubject = PassthroughSubject<Item, AppError>()
        itemSubjects[id.0] = itemSubject
        return itemSubject
            .timeout(.seconds(Self.timeout), scheduler: DispatchQueue.main)
            .first()
            .handleEvents(receiveOutput: { [weak self] _ in self?.getScraperConfigs() })
            .eraseToAnyPublisher()
    }

    func search(searchTerm: String, settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError> {
        let id = id
        interpreter.call(object: nil,
                         functionName: "scraper.api.searchItems",
                         arguments: [searchTerm, DefaultDataController.config(from: settings, exchangeRates: exchangeRates).asJSON!, id.1, scraperConfigArg],
                         completion: { _ in })
        let itemsSubject = PassthroughSubject<[Item], AppError>()
        itemsSubjects[id.0] = itemsSubject
        return itemsSubject
            .timeout(.seconds(Self.timeout), scheduler: DispatchQueue.main)
            .first()
            .handleEvents(receiveOutput: { [weak self] _ in self?.refreshHeadersAndConfigs() })
            .eraseToAnyPublisher()
    }

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

    func getPopularItems(settings: CopDeckSettings, exchangeRates: ExchangeRates) -> AnyPublisher<[Item], AppError> {
        let id = id

        interpreter.call(object: nil,
                         functionName: "scraper.api.getPopularItems",
                         arguments: [DefaultDataController.config(from: settings, exchangeRates: exchangeRates).asJSON!, id.1, scraperConfigArg],
                         completion: { _ in })

        let popularItemsSubject = PassthroughSubject<[Item], AppError>()
        popularItemsSubjects[id.0] = popularItemsSubject

        return popularItemsSubject
            .timeout(.seconds(Self.timeout), scheduler: DispatchQueue.main)
            .first()
            .handleEvents(receiveOutput: { [weak self] _ in self?.getScraperConfigs() })
            .eraseToAnyPublisher()
    }

    func refreshHeadersAndConfigs() {
        getScraperConfigs()
        getImageDownloadHeaders()
    }

    private func getScraperConfigs() {
        interpreter.call(object: nil,
                         functionName: "scraper.api.getScraperConfigs",
                         arguments: [id.1],
                         completion: { _ in })
    }

    private func getImageDownloadHeaders() {
        interpreter.call(object: nil,
                         functionName: "scraper.api.getImageDownloadHeaders",
                         arguments: [id.1],
                         completion: { _ in })
    }
}

extension LocalScraper: JSNativeBridgeDelegate {
    func setExchangeRates(_ exchangeRates: WrappedResult<ExchangeRates>) {
        guard let id = Double(exchangeRates.requestId), let publisher = exchangeRatesSubjects[id] else { return }
        publisher.send(exchangeRates.res)
    }

    func setItems(_ items: WrappedResult<[Item]>) {
        guard let id = Double(items.requestId), let publisher = itemsSubjects[id] else { return }
        publisher.send(items.res)
    }

    func setItem(_ item: WrappedResult<Item>) {
        guard let id = Double(item.requestId), let publisher = itemSubjects[id] else { return }
        publisher.send(item.res)
    }

    func setItemWithCalculatedPrices(_ item: WrappedResult<Item>) {
        guard let id = Double(item.requestId), let publisher = itemWithCalculatedPricesSubjects[id] else { return }
        publisher.send(item.res)
    }
    
    func setScraperConfigsRaw(_ configs: Any) {
        self.scraperConfigRaw = configs
    }

    func setScraperConfigs(_ configs: [ScraperConfig]) {
        if !configs.isEmpty {
            scraperConfigSubject.send(configs)
            
        }
    }

    func setImageDownloadHeaders(_ headers: WrappedResult<[HeadersWithStoreId]>) {
        if !headers.res.isEmpty {
            imageDownloadHeadersSubject.send(headers.res)
        }
    }

    func setPopularItems(_ items: WrappedResult<[Item]>) {
        guard let id = Double(items.requestId), let publisher = popularItemsSubjects[id] else { return }
        if !items.res.isEmpty {
            publisher.send(items.res)
        }
    }

    func setError(_ error: String, requestId: String) {
        guard let id = Double(requestId) else { return }
        exchangeRatesSubjects[id]?.send(completion: .failure(.init(title: "Error", message: error, error: nil)))
        itemsSubjects[id]?.send(completion: .failure(.init(title: "Error", message: error, error: nil)))
        itemSubjects[id]?.send(completion: .failure(.init(title: "Error", message: error, error: nil)))
        itemWithCalculatedPricesSubjects[id]?.send(completion: .failure(.init(title: "Error", message: error, error: nil)))
        popularItemsSubjects[id]?.send(completion: .failure(.init(title: "Error", message: error, error: nil)))
    }
}
