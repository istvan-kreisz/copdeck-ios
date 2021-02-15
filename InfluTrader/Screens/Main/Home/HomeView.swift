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

                HStack(alignment: .bottom) {
                    Text("$10000")
                        .font(.bold(size: 50))
                        .leftAligned()
                    Text("+3%")
                        .font(.bold(size: 16))
                        .leftAligned()
                }

                LineChartView(data: [1, 2, 1, 3, 4, 5, 4],
                              title: "",
                              form: ChartForm.large,
                              rateValue: 20,
                              dropShadow: false)

                Text("Trending Influencers")
                    .font(.bold(size: 22))
                    .leftAligned()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(store.state.trendingStocks ?? []) { stock in
                            AvatarView(imageURL: "https://picsum.photos/200", text: stock.id)
                                .onTapGesture {
                                    selectedStock = stock
                                }
                        }
                    }
                }
            }
            .withDefaultPadding()
            
            ZStack {
                Color.customLightGray3
                Text("Portfolio")
                    .font(.bold(size: 16))
                    .withDefaultPadding()

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
                        .background(Color.clear)
                    }
                }
                .background(Color.clear)
                .withDefaultPadding()
            }
            .edgesIgnoringSafeArea(.all)

            
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
