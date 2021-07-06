//
//  LocalScraper.swift
//  SneakersnShit
//
//  Created by István Kreisz on 6/26/21.
//

import UIKit
import JavaScriptCore
import OasisJSBridge

@objc protocol NativeProtocol: JSExport {
    func setExchangeRates(_ exchangeRates: Any)
//    func setItems(_ items: [Item])
//    func setItem(_ item: Item)
}

@objc class Native: NSObject, NativeProtocol {
    func setExchangeRates(_ exchangeRates: Any) {
        DispatchQueue.main.async {
            print(exchangeRates)
        }
    }

//    func setItems(_ items: [Item]) {
//        DispatchQueue.main.async {
//            print(items)
//        }
//    }
//
//    func setItem(_ item: Item) {
//        DispatchQueue.main.async {
//            print(item)
//        }
//    }
}

class TestLogger: JSBridgeLoggingProtocol {
    func log(level: JSBridgeLoggingLevel, message: String, file: StaticString, function: StaticString, line: UInt) {
        print("[\(level.rawValue)]" + message)
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
        let apiConfig = APIConfig(currency: .init(code: "GBP", symbol: "£"),
                                  isLoggingEnabled: true,
                                  exchangeRates: ["usd": 1.2125, "gbp": 0.8571, "chf": 1.0883, "nok": 10.0828],
                                  feeCalculation: .init(countryName: "Austria",
                                                        stockx: .init(sellerLevel: 1, taxes: 0),
                                                        goat: .init(commissionPercentage: 15, cashOutFee: 2.9, taxes: 0)))
        guard let config = apiConfig.asJSON else { return }

        interpreter.call(object: nil, functionName: "scraper.api.getExchangeRates", arguments: [config], completion: { result in })
    }
}
