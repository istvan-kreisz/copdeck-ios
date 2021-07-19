//
//  CopDeckSettings.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/19/21.
//

import Foundation

struct CopDeckSettings {
    let currency: Currency
    let updateInterval: Double
    let notificationFrequency: Double
    let darkModeOn: Bool
    let feeCalculation: FeeCalculation

    struct FeeCalculation {
        let countryName: String
        let stockx: StockX
        let goat: Goat

        struct StockX {
            enum SellerLevel: Int {
                case Level1 = 1
                case Level2 = 2
                case Level3 = 3
                case Level4 = 4
            }

            let sellerLevel: SellerLevel
            let taxes: Double
        }

        struct Goat {
            enum CommissionPercentage: Double {
                case low = 9.5
                case mid = 15
                case high = 20
            }

            enum CashoutFee: Double {
                case none = 0
                case regular = 0.029
            }

            let commissionPercentage: CommissionPercentage
            let cashOutFee: CashoutFee
            let taxes: Double
        }
    }
}
