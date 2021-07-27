//
//  JSNativeBridge.swift
//  CopDeck
//
//  Created by István Kreisz on 7/8/21.
//

import Foundation
import Combine
import OasisJSBridge

protocol JSNativeBridgeDelegate: AnyObject {
    func setExchangeRates(_ exchangeRates: ExchangeRates)
    func setItems(_ items: [Item])
    func setItem(_ item: Item)
    func setItemWithCalculatedPrices(_ item: Item)
}

@objc protocol NativeProtocol: JSExport {
    func setExchangeRates(_ exchangeRates: Any)
    func setItems(_ items: Any)
    func setItem(_ item: Any)
    func setItemWithCalculatedPrices(_ item: Any)
}

@objc class JSNativeBridge: NSObject, NativeProtocol {

    weak var delegate: JSNativeBridgeDelegate?

    func setExchangeRates(_ exchangeRates: Any) {
        guard let exchangeRates = ExchangeRates(from: exchangeRates) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.setExchangeRates(exchangeRates)
        }
    }

    func setItems(_ items: Any) {
        guard let items = [Item](from: items) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.setItems(items)
        }
    }

    func setItem(_ item: Any) {
        guard let item = Item(from: item) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.setItem(item)
        }
    }

    func setItemWithCalculatedPrices(_ item: Any) {
        guard let item = Item(from: item) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.setItemWithCalculatedPrices(item)
        }
    }
}
