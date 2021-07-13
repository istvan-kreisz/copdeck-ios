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
    @State private var feeType: FeeType = .none

    enum BorderStyle {
        case red, green, regular
    }

    @StateObject private var loader = Loader()

    init(item: Item) {
        self._item = State(initialValue: item)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center, spacing: 20) {
                ImageView(withURL: item.bestStoreInfo?.imageURL ?? "", size: UIScreen.main.bounds.width - 80, aspectRatio: nil)
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.bestStoreInfo?.brand.uppercased() ?? "")
                        .font(.bold(size: 12))
                        .foregroundColor(.customText2)
                    Text(item.bestStoreInfo?.name ?? "")
                        .font(.bold(size: 30))
                        .foregroundColor(.customText1)
                        .padding(.bottom, 8)
                    HStack(spacing: 10) {
                        VStack(spacing: 2) {
                            Text(item.bestStoreInfo?.retailPrice.map { "\(item.currency.symbol.rawValue)\($0.rounded(toPlaces: 1))" } ?? "")
                                .font(.bold(size: 20))
                                .foregroundColor(.customText1)
                            Text("Retail Price")
                                .font(.regular(size: 15))
                                .foregroundColor(.customText2)
                        }
                        Spacer()
                        VStack(spacing: 2) {
                            Text(item.id)
                                .font(.bold(size: 20))
                                .foregroundColor(.customText1)
                            Text("Style")
                                .font(.regular(size: 15))
                                .foregroundColor(.customText2)
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 14)
                .padding(.bottom, 30)

                ZStack {
                    Color.customBackground.edgesIgnoringSafeArea(.all)
                    VStack(alignment: .leading) {
                        Text("Price Comparison")
                            .font(.bold(size: 20))

                        VStack(spacing: 20) {
                            HStack(spacing: 10) {
                                Text("Size")
                                    .font(.regular(size: 14))
                                    .foregroundColor(.customText2)
                                    .frame(maxWidth: .infinity)
                                ForEach(ALLSTORES) { store in
                                    Text(store.name.rawValue)
                                        .font(.bold(size: 18))
                                        .foregroundColor(.customText1)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(5)

                            if loader.isLoading {
                                CustomSpinner(text: "Loading...", animate: true)
                                    .padding(5)
                            }

                            ForEach(item.allPriceRows(priceType: priceType)) { row in
                                HStack(spacing: 10) {
                                    Text(row.size)
                                        .frame(height: 32)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.customAccent2)
                                        .clipShape(Capsule())
                                    ForEach(row.prices) { price in

                                        Text(price.primaryText)
                                            .frame(height: 32)
                                            .frame(maxWidth: .infinity)
                                            .if(price.store.id == row.lowest?.id && (feeType == .buy || feeType == .none)) {
                                                $0.overlay(Capsule().stroke(Color.customGreen, lineWidth: 2))
                                            } else: {
                                                $0.if(price.store.id == row.highest?.id && (feeType == .buy || feeType == .none)) {
                                                    $0.overlay(Capsule().stroke(Color.customRed, lineWidth: 2))
                                                } else: {
                                                    $0.overlay(Capsule().stroke(Color.customAccent1, lineWidth: 2))
                                                }
                                            }
                                    }
                                }
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                            }
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 37)
                }
            }
        }
        .onAppear {
            updateItem(newItem: store.state.selectedItem)
            store.send(.getItemDetails(item: item), completed: loader.getLoader())
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
