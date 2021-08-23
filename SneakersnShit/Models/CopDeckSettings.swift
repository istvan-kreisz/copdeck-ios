//
//  CopDeckSettings.swift
//  CopDeck
//
//  Created by István Kreisz on 7/19/21.
//

import Foundation

struct CopDeckSettings: Codable, Equatable {
    var currency: Currency
//    var updateInterval: Double
//    var notificationFrequency: Double
//    var darkModeOn: Bool
    var feeCalculation: FeeCalculation
    var bestPricePriceType: PriceType
    var bestPriceFeeType: FeeType
    var preferredShoeSize: String?
    var displayedStores: [StoreId]
    var filters: Filters

    struct FeeCalculation: Codable, Equatable {
        var country: Country
        var stockx: StockX?
        var goat: Goat?
        var klekt: Klekt?

        struct StockX: Codable, Equatable {
            enum SellerLevel: Int, Codable, Equatable, CaseIterable {
                case level1 = 1
                case level2 = 2
                case level3 = 3
                case level4 = 4
                case level5 = 5
            }

            var sellerLevel: SellerLevel
            var taxes: Double
            var successfulShipBonus: Bool
            var quickShipBonus: Bool
        }

        struct Goat: Codable, Equatable {
            enum CommissionPercentage: Double, Codable, Equatable, CaseIterable {
                case low = 9.5
                case mid = 15
                case high = 20
            }

            var commissionPercentage: CommissionPercentage
            var cashOutFee: Bool
            var taxes: Double
        }

        struct Klekt: Codable, Equatable {
            var taxes: Double
        }
    }
}

extension CopDeckSettings {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        currency = try container.decode(Currency.self, forKey: .currency)
//        updateInterval = try container.decode(Double.self, forKey: .updateInterval)
//        notificationFrequency = try container.decode(Double.self, forKey: .notificationFrequency)
//        darkModeOn = try container.decode(Bool.self, forKey: .darkModeOn)

        feeCalculation = try container.decode(FeeCalculation.self, forKey: .feeCalculation)
        bestPricePriceType = try container.decodeIfPresent(PriceType.self, forKey: .bestPricePriceType) ?? .Ask
        bestPriceFeeType = try container.decodeIfPresent(FeeType.self, forKey: .bestPriceFeeType) ?? .None
        preferredShoeSize = try container.decodeIfPresent(String.self, forKey: .preferredShoeSize)
        displayedStores = try container.decodeIfPresent([StoreId].self, forKey: .displayedStores) ?? ALLSTORES.map(\.id)
        filters = try container.decodeIfPresent(Filters.self, forKey: .filters) ?? Filters(soldStatus: .All)
    }

    static let `default` = CopDeckSettings(currency: Currency(code: .eur, symbol: .eur),
//                                           updateInterval: 60,
//                                           notificationFrequency: 24,
//                                           darkModeOn: false,
                                           feeCalculation: .init(country: .US,
                                                                 stockx: .init(sellerLevel: .level1,
                                                                               taxes: 0,
                                                                               successfulShipBonus: false,
                                                                               quickShipBonus: false),
                                                                 goat: .init(commissionPercentage: .low,
                                                                             cashOutFee: false,
                                                                             taxes: 0),
                                                                 klekt: .init(taxes: 0)),
                                           bestPricePriceType: .Ask,
                                           bestPriceFeeType: .None,
                                           preferredShoeSize: nil,
                                           displayedStores: ALLSTORES.map(\.id),
                                           filters: .init(soldStatus: .All))
}
