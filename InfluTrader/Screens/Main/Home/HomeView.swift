//
//  HomeView.swift
//  InfluTrader
//
//  Created by István Kreisz on 1/30/21.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: Store<MainState, MainAction, Main>

    func ownedAmount(of stock: Stock) -> Int {
        store.state.user?.transactions
            .first(where: { $0.id == stock.id })
            .map { $0.trades.map { $0.amount }.sum() } ?? 0
    }

    var body: some View {
        VStack {
            Text(store.state.user?.name ?? "")
//            ScrollView {
//                HStack {
//                    ForEach(store.state.trendingStocks ?? []) { stock in
//                        VStack {
//                            ZStack {
//                                Circle()
//                                    .frame(width: 80, height: 80)
//                                Image("profile")
//                                    .frame(width: 60, height: 60)
//                                    .cornerRadius(30)
//                            }
//                            Text(stock.id)
//                        }
//                        .padding()
//                    }
//                }
//            }
            List {
                ForEach(store.state.userStocks ?? []) { stock in
                    HStack {
                        Text(stock.id)
                        Text("\(ownedAmount(of: stock))")
                        Text("\(stock.price)")
                        Button("Buy 1") {
                            store.send(.tradeStock(stockId: stock.id, amount: 1, type: .buy))
                        }
                        Button("Sell 1") {
                            store.send(.tradeStock(stockId: stock.id, amount: 1, type: .sell))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .onAppear {
            print(store.state.user?.name ?? "")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
