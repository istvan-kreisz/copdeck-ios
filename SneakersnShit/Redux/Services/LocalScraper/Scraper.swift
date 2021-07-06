//
//  LocalScraper.swift
//  SneakersnShit
//
//  Created by István Kreisz on 6/26/21.
//

import JavaScriptCore
import OasisJSBridge
import Combine

@objc protocol NativeProtocol: JSExport {
    func setExchangeRates(_ exchangeRates: Any)
    func setItems(_ items: Any)
    func setItem(_ item: Any)
}

@objc class Native: NSObject, NativeProtocol {
    func setExchangeRates(_ exchangeRates: Any) {
        guard let rates = ExchangeRates(from: exchangeRates) else { return }
        DispatchQueue.main.async {
            print(rates)
        }
    }

    func setItems(_ items: Any) {
        guard let items = [SItem](from: items) else { return }
        DispatchQueue.main.async {
            print(items.count)
        }
    }

    func setItem(_ item: Any) {
        guard let item = SItem(from: item) else { return }
        DispatchQueue.main.async {
            print(item)
        }
    }
}

class TestLogger: JSBridgeLoggingProtocol {
    func log(level: JSBridgeLoggingLevel, message: String, file: StaticString, function: StaticString, line: UInt) {
        if level != .verbose {
            print("[\(level.rawValue)]" + message)
        }
    }
}

class LocalScraper {
    static let shared = LocalScraper()

    private let native = Native()
    private lazy var interpreter: JavascriptInterpreter = {
        JSBridgeConfiguration.add(logger: TestLogger())
        let interpreter = JavascriptInterpreter()
        interpreter.jsContext.setObject(native, forKeyedSubscript: "native" as NSString)
        return interpreter
    }()

    let apiConfig = APIConfig(currency: .init(code: "GBP", symbol: "£"),
                              isLoggingEnabled: false,
                              exchangeRates: .init(usd: 1.2125, gbp: 0.8571, chf: 1.0883, nok: 10.0828),
                              feeCalculation: .init(countryName: "Austria",
                                                    stockx: .init(sellerLevel: 1, taxes: 0),
                                                    goat: .init(commissionPercentage: 15, cashOutFee: 2.9, taxes: 0)))

    lazy var config = apiConfig.asJSON!

    private init() {
        guard let scraper = Bundle.main.url(forResource: "scraper.bundle", withExtension: "js"),
              let jsCode = try? String.init(contentsOf: scraper)
        else { return }
        interpreter.evaluateString(js: jsCode) { [weak self] value, error in
            if let error = error {
                DispatchQueue.main.async {
                    print(error)
                }
            } else {
                self?.getExchangeRates()
            }
        }
    }

    func getExchangeRates() {
        interpreter.call(object: nil, functionName: "scraper.api.getExchangeRates", arguments: [config], completion: { result in })
    }
//
//    func searchItems(searchTerm: String) {
//        interpreter.call(object: nil, functionName: "scraper.api.searchItems", arguments: [searchTerm, config], completion: { result in })
//    }
//
//    func search(searchTerm: String) -> AnyPublisher<[Item], AppError> {
//        interpreter.call(object: nil, functionName: "scraper.api.searchItems", arguments: [searchTerm, config], completion: { result in })
//    }
//
//    func getItemDetails(for item: Item) -> AnyPublisher<Item, AppError> {
//
//    }
//    func addToInventory(userId: String, inventoryItem: InventoryItem) -> AnyPublisher<InventoryItem, AppError> {
//
//    }
//
//    func removeFromInventory(userId: String, inventoryItem: InventoryItem) -> AnyPublisher<Void, AppError> {
//
//    }
//
//    func getInventoryItems(userId: String) -> AnyPublisher<[InventoryItem], AppError> {
//
//    }

}
