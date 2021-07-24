//
//  CopDeckSettings.swift
//  CopDeck
//
//  Created by István Kreisz on 7/19/21.
//

import Foundation

struct CopDeckSettings: Codable, Equatable {
    let currency: Currency
    let updateInterval: Double
    let notificationFrequency: Double
    let darkModeOn: Bool
    var feeCalculation: FeeCalculation

    struct FeeCalculation: Codable, Equatable {
        let countryName: String
        var stockx: StockX?
        var goat: Goat?

        struct StockX: Codable, Equatable {
            enum SellerLevel: Int, Codable, Equatable {
                case Level1 = 1
                case Level2 = 2
                case Level3 = 3
                case Level4 = 4
            }

            let sellerLevel: SellerLevel
            let taxes: Double
        }

        struct Goat: Codable, Equatable {
            enum CommissionPercentage: Double, Codable, Equatable {
                case low = 9.5
                case mid = 15
                case high = 20
            }

            enum CashoutFee: Double, Codable, Equatable {
                case none = 0
                case regular = 0.029
            }

            let commissionPercentage: CommissionPercentage
            let cashOutFee: CashoutFee
            let taxes: Double
        }
    }
}
