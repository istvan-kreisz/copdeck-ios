//
//  Constants.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/18/21.
//

import Foundation

extension World {
    enum Constants {
        static var itemPricesRefreshPeriodMin: Double { double(for: #function, defaultValue: 30) }
        static let _lifetimePriceCheckLimit = 15
        static let _stacksLimit = 1
        
        static var lifetimePriceCheckLimit: Int {
            AppStore.default.state.globalState.remoteConfig?.lifetimePriceCheckLimit ?? _lifetimePriceCheckLimit
        }
        
        static var stacksLimit: Int {
            AppStore.default.state.globalState.remoteConfig?.stacksLimit ?? _stacksLimit
        }
    }
}

extension World.Constants {
    private static func double(for key: String, defaultValue: Double) -> Double {
        if DebugSettings.shared.isInDebugMode {
            return DebugSettings.shared.double(for: key) ?? defaultValue
        } else {
            return defaultValue
        }
    }
}

