//
//  SellerStatsView.swift
//  CopDeck
//
//  Created by István Kreisz on 10/2/21.
//

import Foundation
import SwiftUI
import Firebase

struct SellerStatsView: View {
    let inventoryItems: [InventoryItem]
    let currency: Currency
    let exchangeRates: ExchangeRates

    @State private var isFirstload = true

    var monthlyStats: [MonthlyStatistics] {
        InventoryItem.monthlyStatistics(for: inventoryItems, currency: currency, exchangeRates: exchangeRates)
    }

    var monthlyStatsLocked: [MonthlyStatistics] {
        monthlyStats.first(n: 1)
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

    private func amountWithCurrency(_ number: Double) -> String {
        "\(currency.symbol.rawValue)\(Int(number))"
    }

    var body: some View {
        VerticalListView(bottomPadding: 20, spacing: 10, addHorizontalPadding: false) {
            Text("Seller Stats")
                .font(.bold(size: 28))
                .foregroundColor(.customText1)
                .padding(.bottom, 18)
                .padding(.top, 8)
                .centeredHorizontally()

            ForEach(isContentLocked ? monthlyStatsLocked : monthlyStats) { stats in
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
                        infoStack(title: "Revenue", value: amountWithCurrency(stats.revenue))
                        Spacer()
                        infoStack(title: "Cost", value: amountWithCurrency(stats.cost))
                        Spacer()
                        infoStack(title: "Profit", value: amountWithCurrency(stats.profit))
                    }
                    .padding(.top, 5)
                }
                .asCard()
                .withDefaultPadding(padding: .horizontal)
            }
            if monthlyStats.count != monthlyStatsLocked.count, isContentLocked {
                EmptyView()
                    .lockedContent(displayStyle: .hideOriginal, contentSttyle: .textWithLock(text: "Upgrade to pro to see all months!", size: 20, color: .customBlue))
            }
        }
        .withBackgroundColor()
        .preferredColorScheme(.light)
        .onAppear {
            if isFirstload {
                Analytics.logEvent("visited_stats", parameters: ["userId": AppStore.default.state.user?.id ?? ""])
                isFirstload = false
            }
        }
    }
}
