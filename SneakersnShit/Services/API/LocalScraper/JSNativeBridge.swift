//
//  JSNativeBridge.swift
//  CopDeck
//
//  Created by István Kreisz on 7/8/21.
//

import Foundation
import Combine
import OasisJSBridge

struct WrappedResult<T: Codable>: Codable {
    let res: T
    let requestId: String
}

protocol JSNativeBridgeDelegate: AnyObject {
    func setExchangeRates(_ exchangeRates: WrappedResult<ExchangeRates>)
    func setItems(_ items: WrappedResult<[Item]>)
    func setItem(_ item: WrappedResult<Item>)
    func setItemWithCalculatedPrices(_ item: WrappedResult<Item>)
    func setScraperConfigs(_ configs: [ScraperConfig])
    func setScraperConfigsRaw(_ configs: Any)
    func setImageDownloadHeaders(_ headers: WrappedResult<[HeadersWithStoreId]>)
    func setPopularItems(_ items: WrappedResult<[Item]>)
    func setError(_ error: String, requestId: String)
}

@objc protocol NativeProtocol: JSExport {
    func setExchangeRates(_ exchangeRates: Any)
    func setItems(_ items: Any)
    func setItem(_ item: Any)
    func setItemWithCalculatedPrices(_ item: Any)
    func setScraperConfigs(_ configs: Any)
    func setImageDownloadHeaders(_ headers: Any)
    func setPopularItems(_ items: Any)
    func setError(_ error: Any, requestId: Any)
}

@objc class JSNativeBridge: NSObject, NativeProtocol {
    weak var delegate: JSNativeBridgeDelegate?

    func setExchangeRates(_ exchangeRates: Any) {
        guard let exchangeRates = WrappedResult<ExchangeRates>(from: exchangeRates) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.setExchangeRates(exchangeRates)
        }
    }

    func setItems(_ items: Any) {
        guard let items = WrappedResult<[Item]>(from: items) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.setItems(items)
        }
    }

    func setItem(_ item: Any) {
        guard let item = WrappedResult<Item>(from: item) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.setItem(item)
        }
    }

    func setItemWithCalculatedPrices(_ item: Any) {
        guard let item = WrappedResult<Item>(from: item) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.setItemWithCalculatedPrices(item)
        }
    }

    func setScraperConfigs(_ configs: Any) {
        delegate?.setScraperConfigsRaw(configs)
        guard let scraperConfigs = [ScraperConfig](from: configs) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.setScraperConfigs(scraperConfigs)
        }
    }

    func setImageDownloadHeaders(_ headers: Any) {
        guard let headers = WrappedResult<[HeadersWithStoreId]>(from: headers) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.setImageDownloadHeaders(headers)
        }
    }

    func setPopularItems(_ items: Any) {
        guard let items = WrappedResult<[Item]>(from: items) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.setPopularItems(items)
        }
    }

    func setError(_ error: Any, requestId: Any) {
        if let error = error as? String, let requestId = requestId as? String {
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.setError(error, requestId: requestId)
            }
        }
    }
}
