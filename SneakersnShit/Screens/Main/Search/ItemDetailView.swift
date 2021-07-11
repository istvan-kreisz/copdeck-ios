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
            VStack(alignment: .center, spacing: 20) {
                ImageView(withURL: item.bestStoreInfo?.imageURL ?? "", size: UIScreen.main.bounds.width - 80, aspectRatio: nil)
                VStack {
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
                }
                Text("Price Comparison")
                    .font(.bold(size: 20))

                VStack(spacing: 20) {
                    ForEach(item.allPriceRows(priceType: priceType)) { row in
                        HStack(spacing: 5) {
                            Text(row.size)
                                .frame(maxWidth: .infinity)
                                .overlay(Capsule().stroke(Color.blue, lineWidth: 2))
                            ForEach(row.prices) { price in
                                Text(price.primaryText)
                                    .frame(maxWidth: .infinity)
                                    .overlay(Capsule().stroke(Color.blue, lineWidth: 2))
                            }
                        }
                        .padding(5)
                    }
                }
                Spacer()
            }
        }
        .navigationBarHidden(false)
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
        let storeInfo = Item.StoreInfo(name: "Stockx",
                                       sku: "GHVDY45",
                                       slug: "",
                                       retailPrice: 234,
                                       brand: "Adidas",
                                       store: Store(id: .stockx, name: .StockX),
                                       imageURL: "",
                                       url: "",
                                       sellUrl: "",
                                       buyUrl: "",
                                       productId: "")
        return ItemDetailView(item: .init(id: "GHVDY45",
                                          storeInfo: [storeInfo],
                                          storePrices: [],
                                          ownedByCount: 0,
                                          priceAlertCount: 0,
                                          created: 0,
                                          updated: 0,
                                          name: "yolo",
                                          retailPrice: 12,
                                          imageURL: nil))
    }
}
