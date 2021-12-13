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
    func setItemWithCalculatedPrices(_ item: WrappedResult<Item>)
    func setError(_ error: String, requestId: String)
}

@objc protocol NativeProtocol: JSExport {
    func setItemWithCalculatedPrices(_ item: Any)
    func setError(_ error: Any, requestId: Any)
}

@objc class JSNativeBridge: NSObject, NativeProtocol {
    weak var delegate: JSNativeBridgeDelegate?

    func setItemWithCalculatedPrices(_ item: Any) {
        guard let item = WrappedResult<Item>(from: item) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.setItemWithCalculatedPrices(item)
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
