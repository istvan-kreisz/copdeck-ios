//
//  Purchases+Extensions.swift
//  CopDeck
//
//  Created by István Kreisz on 10/25/21.
//

import Foundation
import Purchases

extension Purchases.Package: Identifiable {
    public var id: String { identifier }
}

/* Some methods to make displaying subscription terms easier */

extension Purchases.Package {
    func terms(for package: Purchases.Package) -> String {
        if let intro = package.product.introductoryPrice {
            if intro.price == 0 {
                return "\(intro.subscriptionPeriod.periodTitle()) free trial"
            } else {
                return "\(package.localizedIntroductoryPriceString) for \(intro.subscriptionPeriod.periodTitle())"
            }
        } else {
            return "Unlocks Premium"
        }
    }
}

extension SKProductSubscriptionPeriod {
    var durationTitle: String {
        switch self.unit {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        default: return "Unknown"
        }
    }

    func periodTitle() -> String {
        let periodString = "\(self.numberOfUnits) \(self.durationTitle)"
        let pluralized = self.numberOfUnits > 1 ? periodString + "s" : periodString
        return pluralized
    }
}
