//
//  ItemDetailView.swift
//  CopDeck
//
//  Created by István Kreisz on 3/28/21.
//

import SwiftUI
import Combine

struct ItemDetailView: View {
    @EnvironmentObject var store: AppStore
    @State private var item: Item?
    @State private var priceType: PriceType = .ask
    @State private var feeType: FeeType = .none

    @State private var addToInventory = false
    @State private var addedInventoryItem = false
    @State private var firstShow = true
    @State var showSnackBar = false

    private let itemId: String
    private let showAddToInventoryButton: Bool

    enum BorderStyle {
        case red, green, regular
    }

    @StateObject private var loader = Loader()

    init(item: Item?, itemId: String, showAddToInventoryButton: Bool = true) {
        self._item = State(initialValue: item)
        self.itemId = itemId
        self.showAddToInventoryButton = showAddToInventoryButton
    }

    var body: some View {
        ZStack {
            Color.customWhite.edgesIgnoringSafeArea(.all)
            if let item = item, showAddToInventoryButton {
                NavigationLink("",
                               destination: AddToInventoryView(item: item, presented: $addToInventory, addedInvantoryItem: $addedInventoryItem),
                               isActive: $addToInventory)
            }

            ScrollView(.vertical, showsIndicators: false) {
                ScrollViewReader { scrollViewProxy in
                    VStack(alignment: .center, spacing: 20) {
                        ItemImageViewWithNavBar(imageURL: item?.imageURL)
                            .id(0)

                        ZStack {
                            Color.customBackground.edgesIgnoringSafeArea(.all)
                            VStack(alignment: .leading, spacing: 8) {
                                Text((item?.bestStoreInfo?.brand.uppercased()) ?? "")
                                    .font(.bold(size: 12))
                                    .foregroundColor(.customText2)
                                Text((item?.bestStoreInfo?.name) ?? "")
                                    .font(.bold(size: 30))
                                    .foregroundColor(.customText1)
                                    .padding(.bottom, 8)
                                HStack(spacing: 10) {
                                    Spacer()
                                    VStack(spacing: 2) {
                                        Text(item?.id ?? "")
                                            .font(.bold(size: 20))
                                            .foregroundColor(.customText1)
                                        Text("Style")
                                            .font(.regular(size: 15))
                                            .foregroundColor(.customText2)
                                    }
                                    Spacer()
                                    VStack(spacing: 2) {
                                        Text(item?.bestStoreInfo?.retailPrice.map { "\(item?.currency.symbol.rawValue ?? "")\($0.rounded(toPlaces: 1))" } ?? "")
                                            .font(.bold(size: 20))
                                            .foregroundColor(.customText1)
                                        Text("Retail Price")
                                            .font(.regular(size: 15))
                                            .foregroundColor(.customText2)
                                    }
                                    Spacer()
                                }
                            }
                            .withDefaultPadding(padding: .horizontal)
                            .padding(.top, 14)
                            .padding(.bottom, 20)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Price Comparison")
                                .font(.bold(size: 20))
                            Text("Tap price to visit website")
                                .font(.regular(size: 14))
                                .foregroundColor(.customText2)

                            VStack(alignment: .leading, spacing: 20) {
                                HStack(spacing: 10) {
                                    ForEach(PriceType.allCases) { priceType in
                                        Text(priceType.rawValue.capitalized)
                                            .frame(width: 60, height: 31)
                                            .if(priceType == self.priceType) {
                                                $0
                                                    .foregroundColor(Color.customWhite)
                                                    .background(Capsule().fill(Color.customBlue))
                                            } else: {
                                                $0
                                                    .foregroundColor(Color.customText1)
                                                    .background(Capsule().stroke(Color.customBlue, lineWidth: 2))
                                            }
                                            .onTapGesture {
                                                self.priceType = priceType
                                            }
                                    }
                                }
                                HStack(spacing: 10) {
                                    ForEach(FeeType.allCases) { feeType in
                                        Text(feeType.rawValue.capitalized)
                                            .frame(width: 60, height: 31)
                                            .if(feeType == self.feeType) {
                                                $0
                                                    .foregroundColor(Color.customWhite)
                                                    .background(Capsule().fill(Color.customPurple))
                                            } else: {
                                                $0
                                                    .foregroundColor(Color.customText1)
                                                    .background(Capsule().stroke(Color.customPurple, lineWidth: 2))
                                            }
                                            .onTapGesture {
                                                self.feeType = feeType
                                            }
                                    }
                                }
                                .padding(.top, -10)

                                HStack(alignment: .center, spacing: 3) {
                                    Text("Refresh Prices")
                                        .foregroundColor(.customOrange)
                                        .font(.bold(size: 16))
                                    Image(systemName: "arrow.clockwise")
                                        .font(.bold(size: 13))
                                        .foregroundColor(.customOrange)
                                }
                                .padding(.top, 5)
                                .padding(.bottom, -5)
                                .onTapGesture {
                                    refreshPrices(forced: true)
                                }

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
                                            .onTapGesture {
                                                if let link = item?.storeInfo.first(where: { $0.store.id == store.id })?.url,
                                                   let url = URL(string: link) {
                                                    UIApplication.shared.open(url)
                                                }
                                            }
                                    }
                                }
                                .padding(5)

                                if loader.isLoading {
                                    CustomSpinner(text: "Loading...", animate: true)
                                        .padding(5)
                                }

                                ForEach((item?.allPriceRows(priceType: priceType, feeType: feeType)) ?? []) { (row: Item.PriceRow) in
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
                                                    $0.if(price.store.id == row.highest?.id && (feeType == .sell || feeType == .none)) {
                                                        $0.overlay(Capsule().stroke(Color.customRed, lineWidth: 2))
                                                    } else: {
                                                        $0.overlay(Capsule().stroke(Color.customAccent1, lineWidth: 2))
                                                    }
                                                }
                                                .onTapGesture {
                                                    var link: String?
                                                    switch feeType {
                                                    case .buy:
                                                        link = price.buyLink
                                                    case .sell:
                                                        link = price.sellLink
                                                    case .none:
                                                        link = price.buyLink
                                                    }
                                                    if let link = link, let url = URL(string: link) {
                                                        UIApplication.shared.open(url)
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
                        .padding(.bottom, 100)
                    }

                    .onAppear { scrollViewProxy.scrollTo(0) }
                }
            }
            .if(item != nil && showAddToInventoryButton) {
                $0
                    .withFloatingButton(button: NextButton(text: "Add to Inventory",
                                                           size: .init(width: 260, height: 60),
                                                           color: .customBlack,
                                                           tapped: {
                                                               addToInventory = true
                                                               addedInventoryItem = false
                                                           })
                            .disabled(loader.isLoading)
                            .centeredHorizontally()
                            .padding(.top, 20))
            }
            .withSnackBar(text: "Added to inventory", shouldShow: $showSnackBar)
            .navigationbarHidden()
            .onAppear {
                store.send(.main(action: .setSelectedItem(item: nil)))
                if firstShow {
                    firstShow = false
                    refreshPrices(forced: false)
                }
            }
            .onChange(of: store.state.selectedItem) { item in
                updateItem(newItem: item)
            }
            .onChange(of: addedInventoryItem) { new in
                if new {
                    showSnackBar = true
                }
            }
        }
    }

    private func refreshPrices(forced: Bool) {
        store.send(.main(action: .getItemDetails(item: item, itemId: itemId, forced: forced)), completed: loader.getLoader())
    }

    private func updateItem(newItem: Item?) {
        guard let newItem = newItem else { return }
        if let item = self.item {
            if newItem.id == item.id {
                self.item = newItem
            }
        } else {
            self.item = newItem
        }
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
                                          imageURL: nil),
                              itemId: "GHVDY45")
    }
}
