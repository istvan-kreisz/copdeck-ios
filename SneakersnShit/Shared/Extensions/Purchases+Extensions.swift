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

extension Purchases.Package {
    var introductoryPeriodString: String? {
        product.introductoryPrice?.subscriptionPeriod.periodTitle()
    }

    var freePeriodString: String? {
        product.introductoryPrice?.price == 0 ? introductoryPeriodString : nil
    }
    
    var terms: String {
        if let intro = product.introductoryPrice {
            if intro.price == 0 {
                return "\(intro.subscriptionPeriod.periodTitle()) free"
            } else {
                return "\(localizedIntroductoryPriceString) for \(intro.subscriptionPeriod.periodTitle())"
            }
        } else {
            return "\(localizedPriceString)"
        }
    }


    var termsFull: String {
        if let intro = product.introductoryPrice {
            if intro.price == 0 {
                return "Start your \(intro.subscriptionPeriod.periodTitle()) free trial"
            } else {
                return "Start at \(localizedIntroductoryPriceString) for \(intro.subscriptionPeriod.periodTitle())"
            }
        } else {
            return "Subscribe for \(localizedPriceString)"
        }
    }

    var duration: String {
        self.packageType == Purchases.PackageType.monthly ? "month" : "year"
    }
    
    func priceString(for packageType: Purchases.PackageType) -> String? {
        guard let currencySymbol = product.priceLocale.currencySymbol else { return nil }
        var price: Double?
        if self.packageType == Purchases.PackageType.monthly {
            switch packageType {
            case .monthly:
                price = Double(truncating: product.price)
            case .annual:
                price = Double(truncating: product.price) * 12.0
            case .weekly:
                price = Double(truncating: product.price) * 12.0 / 52.0
            default:
                break
            }
        } else if self.packageType == Purchases.PackageType.annual {
            switch packageType {
            case .monthly:
                price = Double(truncating: product.price) / 12.0
            case .annual:
                price = Double(truncating: product.price)
            case .weekly:
                price = Double(truncating: product.price) / 52.0
            default:
                break
            }
        }
        guard let price = price else { return nil }
        return "\(currencySymbol)\(price.keepingDecimalPlaces(2))"
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
