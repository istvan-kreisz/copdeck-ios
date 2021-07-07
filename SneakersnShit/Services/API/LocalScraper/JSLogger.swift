//
//  JSLogger.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/8/21.
//

import Foundation
import OasisJSBridge

class JSLogger: JSBridgeLoggingProtocol {
    func log(level: JSBridgeLoggingLevel, message: String, file: StaticString, function: StaticString, line: UInt) {
        if level != .verbose {
            print("[\(level.rawValue)]" + message)
        }
    }
}
