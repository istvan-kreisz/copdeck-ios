//
//  SellerStatsView.swift
//  CopDeck
//
//  Created by István Kreisz on 10/2/21.
//

import Foundation
import SwiftUI

struct SellerStatsView: View {
    let inventoryItems: [InventoryItem]

    var monthlyStats: [MonthlyStatistics] {
        InventoryItem.monthlyStatistics(for: inventoryItems)
    }

    @ViewBuilder func infoStack(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.bold(size: 20))
                .foregroundColor(.customText1)
            Text(title)
                .font(.regular(size: 15))
                .foregroundColor(.customText2)
        }
    }

    var body: some View {
        VerticalListView(bottomPadding: 20, spacing: 10, addHorizontalPadding: false) {
            Text("Seller Stats")
                .font(.bold(size: 28))
                .foregroundColor(.customText1)
                .padding(.bottom, 18)
                .padding(.top, 8)
                .centeredHorizontally()

            ForEach(monthlyStats) { stats in
                VStack {
                    Text("\(Calendar.current.monthSymbols[stats.month - 1]) \(stats.year):".uppercased())
                        .font(.bold(size: 12))
                        .foregroundColor(.customText2)
                        .leftAligned()

                    HStack {
                        infoStack(title: "Bought", value: "\(stats.purchasedCount)")
                        Spacer()
                        infoStack(title: "Sold", value: "\(stats.soldCount)")
                    }
                    .padding(.top, 5)

                    HStack {
                        infoStack(title: "Revenue", value: "\(Int(stats.revenue))")
                        Spacer()
                        infoStack(title: "Cost", value: "\(Int(stats.cost))")
                        Spacer()
                        infoStack(title: "Profit", value: "\(Int(stats.profit))")
                    }
                    .padding(.top, 5)
                }
                .asCard()
                .withDefaultPadding(padding: .horizontal)
            }
        }
        .withBackgroundColor()
        .preferredColorScheme(.light)
    }
}
