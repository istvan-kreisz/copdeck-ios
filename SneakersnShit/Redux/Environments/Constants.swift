//
//  Constants.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/18/21.
//

import Foundation

extension World {
    enum Constants {
        #warning("change?")
        static var itemPricesRefreshPeriodMin: Double { double(for: #function, defaultValue: 40) }
        static var priceCheckRefreshIntervalMin: Double { double(for: #function, defaultValue: 25) }
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

