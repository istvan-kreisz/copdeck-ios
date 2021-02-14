//
//  HomeView.swift
//  InfluTrader
//
//  Created by István Kreisz on 1/30/21.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: Store<MainState, MainAction, Main>

    let colors: [Color] = [.red, .yellow, .green, .purple, .orange]

    @State var selectedStock: Stock?

    func ownedAmount(of stock: Stock) -> Int {
        store.state.user?.transactions
            .first(where: { $0.id == stock.id })
            .map { $0.trades.map { $0.amount }.sum() } ?? 0
    }

    var body: some View {
        ZStack {
            VStack {
                Text("Welcome " + (store.state.user?.name ?? "") + "!")
                    .font(.bold(size: 25))
                    .leftAligned()

                Text("Your portfolio's value:")
                    .font(.regular(size: 12))
                    .foregroundColor(.customLightGray1)
                    .leftAligned()
                
                Text("$10000")
                    .font(.bold(size: 50))
                    .leftAligned()


                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(store.state.trendingStocks ?? []) { stock in
                            VStack {
                                ZStack {
                                    Circle()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(colors.randomElement()!)
                                    Image("profile")
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(30)
                                }
                                Text(stock.id)
                            }
                            .padding()
                            .onTapGesture {
                                selectedStock = stock
                            }
                        }
                    }
                }
                .frame(height: 100)
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
            .withDefaultPadding()
            if selectedStock != nil {
                StockView(stock: $selectedStock)
                    .transition(.scale)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0))
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let store = AppStore(initialState: .mockAppState,
                             reducer: appReducer,
                             environment: World(isMockInstance: true))
        return Group {
            HomeView()
                .environmentObject(store
                    .derived(deriveState: \.mainState,
                             deriveAction: AppAction.main,
                             derivedEnvironment: store.environment.main))
        }
    }
}

struct StockView: View {
    @Binding var stock: Stock?

    var body: some View {
        VStack {
            Text(stock?.id ?? "nah")
            Button(action: {
                self.stock = nil
            }) {
                    Text("Click me")
            }
            .frame(width: 30, height: 30)
        }
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
        .background(Color.green)
        .edgesIgnoringSafeArea(.all)
    }
}
