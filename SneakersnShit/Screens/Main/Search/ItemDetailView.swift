//
//  ItemDetailView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 3/28/21.
//

import SwiftUI
import Combine

struct ItemDetailView: View {
    @EnvironmentObject var store: MainStore
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
//                    item.priceTable.first.map { prices in
//                        VStack(spacing: 10) {
//                            Text("Size")
//                                .font(.regular(size: 12))
//                            VStack(spacing: 5) {
//                                ForEach(prices.inventory) { price in
//                                    Text(price.size)
//                                }
//                            }
//                        }
//                    }
//                    ForEach(item.priceTable) { prices in
//                        VStack(spacing: 10) {
//                            Text(prices.store)
//                                .font(.regular(size: 12))
//                            VStack(spacing: 5) {
//                                ForEach(prices.inventory) { price in
////                                    Text(price.lowestAsk.map { "$\($0)" } ?? "-")
//                                }
//                            }
//                        }
//                    }
                }
                Spacer()
            }
        }
        .withDefaultPadding(padding: [.top, .leading, .trailing])
        .onAppear {
            updateItem(newItem: store.state.selectedItem)
            store.send(.getItemDetails(item: item))
        }
        .onChange(of: store.state.selectedItem) { item in
            updateItem(newItem: item)
        }
    }

    private func updateItem(newItem: Item?) {
        guard let newItem = newItem, newItem.id == self.item.id else { return }
        self.item = newItem
    }
}

struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ItemDetailView(item: .init(id: "",
                                   storeInfo: [],
                                   storePrices: [],
                                   ownedByCount: 0,
                                   priceAlertCount: 0,
                                   created: 0,
                                   updated: 0,
                                   name: "name",
                                   retailPrice: 12,
                                   imageURL: nil))
    }
}
