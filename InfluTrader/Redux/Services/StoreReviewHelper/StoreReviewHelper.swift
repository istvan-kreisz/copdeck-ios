//
//  StoreReviewHelper.swift
//  InfluTrader
//
//  Created by István Kreisz on 2/1/21.
//

import Foundation
import StoreKit

struct StoreReviewHelper {
    private static let appOpenedCountKey = "appOpenedCount"
    
    static func incrementAppOpenedCount() { // called from appdelegate didfinishLaunchingWithOptions:
        let currentValue = UserDefaults.standard.integer(forKey: Self.appOpenedCountKey)
        UserDefaults.standard.set(currentValue + 1, forKey: Self.appOpenedCountKey)
    }

    static func checkAndAskForReview() {
        let appOpenCount = UserDefaults.standard.integer(forKey: Self.appOpenedCountKey)

        switch appOpenCount {
        case 20, 50:
            StoreReviewHelper().requestReview()
        case _ where appOpenCount % 100 == 0:
            StoreReviewHelper().requestReview()
        default:
            print("App run count is : \(appOpenCount)")
        }
    }

    private func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
}
