//
//  PaymentView2.swift
//  CopDeck
//
//  Created by István Kreisz on 10/26/21.
//

import SwiftUI

struct PaymentView2: View {
    @EnvironmentObject var store: DerivedGlobalStore
    
    var discountPercentage: Int? {
        guard let monthlyPackage = store.globalState.packages?.monthlyPackage,
              let yearlyPackage = store.globalState.packages?.yearlyPackage
        else { return nil }
        let yearlyPrice = Double(truncating: yearlyPackage.product.price)
        let monthlyPrice = Double(truncating: monthlyPackage.product.price)
        let percentage = 100 * ((monthlyPrice * 12.0) - yearlyPrice) / (monthlyPrice * 12.0)
        return Int(round(percentage))
    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            if let monthlyPackage = store.globalState.packages?.monthlyPackage {
                PackageCellView(color: .customBlue,
                                discountPercentage: nil,
                                package: monthlyPackage) { package in
                    store.send(.paymentAction(action: .purchase(package: monthlyPackage)))
                }
            }
            if let yearlyPackage = store.globalState.packages?.yearlyPackage {
                PackageCellView(color: .customPurple,
                                discountPercentage: discountPercentage,
                                package: yearlyPackage) { package in
                    store.send(.paymentAction(action: .purchase(package: yearlyPackage)))
                }
            }
        }
        .frame(width: 400)
        .centeredHorizontally()
    }
    
}
