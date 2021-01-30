//
//  HomeView.swift
//  InfluTrader
//
//  Created by István Kreisz on 1/30/21.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: Store<MainState, FunctionAction, Main>

    var body: some View {
        VStack {
            Text(store.state.user?.name ?? "no")
            List {
                ForEach(store.state.userStocksArray) { stock in
                    HStack {
                        Text(stock.stock.name ?? "")
                        Text("\(stock.amount)")
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
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
