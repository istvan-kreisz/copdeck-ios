//
//  ItemDetailView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 3/28/21.
//

import SwiftUI
import Combine

struct ItemDetailView: View {
    @EnvironmentObject var store: Store<MainState, MainAction, Main>
    @State private var item: Item

    init(item: Item) {
        self._item = State(initialValue: item)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                ImageView(withURL: item.bestStoreInfo?.imageURL ?? "", size: UIScreen.main.bounds.width - 60)
                Text(item.bestStoreInfo?.brand ?? "")
                    .font(.semiBold(size: 13))
                Text(item.bestStoreInfo?.name ?? "")
                    .font(.regular(size: 17))
                HStack(spacing: 10) {
                    VStack(spacing: 10) {
                        Text(item.bestStoreInfo?.retailPrice.map { "$\($0)" } ?? "")
                            .font(.bold(size: 15))
                        Text("Retail Price")
                            .font(.regular(size: 13))
                    }
                    Spacer()
                    VStack(spacing: 10) {
                        Text(item.id)
                            .font(.bold(size: 15))
                        Text("Style")
                            .font(.regular(size: 13))
                    }
                }
                Text("Price Comparison")
                    .font(.bold(size: 20))

                HStack(spacing: 20) {
                    ForEach(item.storePrices) { prices in
                        VStack(spacing: 10) {
                            Text(prices.store.rawValue)
                                .font(.regular(size: 12))
                            VStack(spacing: 5) {
                                ForEach(prices.inventory) { price in
                                    Text("$\(price.lowestAsk)")
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
        }
        .withDefaultPadding(padding: [.top, .leading, .trailing])
        .onAppear {
            store.send(.getItemDetails(item: item))
        }
        .onChange(of: store.state.selectedItem) { item in
            guard let item = item else { return }
            self.item.storePrices = item.storePrices
        }
    }
}

struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ItemDetailView(item: .init(id: "123",
                                   ownedByCount: 0,
                                   priceAlertCount: 0,
                                   storeInfo: [],
                                   storePrices: [],
                                   created: 0,
                                   updated: 0))
    }
}
