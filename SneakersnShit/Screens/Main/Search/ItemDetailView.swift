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
    @State private var priceType: PriceType = .ask

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

                VStack(spacing: 20) {
                    ForEach(item.allPriceRows(priceType: priceType)) { row in
                        HStack(spacing: 5) {
                            ForEach(row.prices) { price in
                                Text(price.primaryText)
                            }
                        }
                    }
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
