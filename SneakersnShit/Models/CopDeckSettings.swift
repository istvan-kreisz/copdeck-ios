//
//  CopDeckSettings.swift
//  CopDeck
//
//  Created by István Kreisz on 7/19/21.
//

import Foundation

struct CopDeckSettings: Codable, Equatable {
    var currency: Currency
    var feeCalculation: FeeCalculation
    var bestPricePriceType: PriceType
    var bestPriceFeeType: FeeType
    var preferredShoeSize: String?
    var displayedStores: [StoreId]
    var shoeSize: ShoeSize
    var filters: Filters

    struct FeeCalculation: Codable, Equatable {
        var country: Country
        var stockx: StockX?
        var goat: Goat?
        var klekt: Klekt?

        struct StockX: Codable, Equatable {
            var sellerFee: Double?
            var taxes: Double
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
        feeCalculation = try container.decode(FeeCalculation.self, forKey: .feeCalculation)
        bestPricePriceType = try container.decodeIfPresent(PriceType.self, forKey: .bestPricePriceType) ?? .Ask
        bestPriceFeeType = try container.decodeIfPresent(FeeType.self, forKey: .bestPriceFeeType) ?? .None
        preferredShoeSize = try container.decodeIfPresent(String.self, forKey: .preferredShoeSize)
        displayedStores = try container.decodeIfPresent([StoreId].self, forKey: .displayedStores) ?? ALLSTORES.map(\.id)
        shoeSize = try container.decodeIfPresent(ShoeSize.self, forKey: .shoeSize) ?? .US
        filters = try container.decodeIfPresent(Filters.self, forKey: .filters) ?? Filters.default
    }

    static let `default` = CopDeckSettings(currency: Currency(code: .eur, symbol: .eur),
                                           feeCalculation: .init(country: .US,
                                                                 stockx: .init(sellerFee: nil, taxes: 0),
                                                                 goat: .init(commissionPercentage: .low,
                                                                             cashOutFee: false,
                                                                             taxes: 0),
                                                                 klekt: .init(taxes: 0)),
                                           bestPricePriceType: .Ask,
                                           bestPriceFeeType: .None,
                                           preferredShoeSize: nil,
                                           displayedStores: ALLSTORES.map(\.id),
                                           shoeSize: .US,
                                           filters: .default)
}
