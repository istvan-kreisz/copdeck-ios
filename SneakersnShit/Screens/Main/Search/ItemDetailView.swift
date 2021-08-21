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

    @State private var addToInventory: (isActive: Bool, size: String?) = (false, nil)
    @State private var addedInventoryItem = false
    @State private var firstShow = true
    @State var showSnackBar = false

    var shouldDismiss: () -> Void

    private let itemId: String

    enum BorderStyle {
        case red, green, regular
    }

    @StateObject private var loader = Loader()

    init(item: Item?, itemId: String, shouldDismiss: @escaping () -> Void) {
        self._item = State(initialValue: item)
        self.itemId = itemId
        self.shouldDismiss = shouldDismiss
    }

    private func priceRow(row: Item.PriceRow) -> some View {
        HStack(spacing: 10) {
            Button(action: {
                addToInventory = (true, row.size)
            }) {
                    ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
                        Text(row.size)
                            .frame(height: 32)
                            .frame(maxWidth: 90)
                            .background(Color.customAccent2)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.customBlue, lineWidth: 2))
                        ZStack {
                            Circle()
                                .fill(Color.customBlue)
                                .frame(width: 18, height: 18)
                            Image(systemName: "plus")
                                .font(.bold(size: 9))
                                .foregroundColor(Color.customWhite)
                        }
                        .frame(width: 18, height: 18)
                        .offset(x: 7, y: 0)
                    }
            }

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
            Spacer()
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
    }

    var body: some View {
        ZStack {
            Color.customWhite.edgesIgnoringSafeArea(.all)
            let isAddToInventoryActive = Binding<Bool>(get: { addToInventory.isActive },
                                                       set: { addToInventory = $0 ? addToInventory : (false, nil) })
            NavigationLink(destination: EmptyView()) { EmptyView() }

            NavigationLink("",
                           destination: item
                               .map { item in AddToInventoryView(item: item, presented: $addToInventory, addedInvantoryItem: $addedInventoryItem) } ??
                               nil,
                           isActive: isAddToInventoryActive)

            ScrollView(.vertical, showsIndicators: false) {
                ScrollViewReader { scrollViewProxy in
                    VStack(alignment: .center, spacing: 20) {
                        ItemImageViewWithNavBar(imageURL: item?.imageURL, requestInfo: store.state.requestInfo, shouldDismiss: shouldDismiss)
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
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Price Comparison")
                                    .font(.bold(size: 25))
                                Text("Tap price to visit website")
                                    .font(.regular(size: 14))
                                    .foregroundColor(.customText2)
                            }
                            .padding(.bottom, 20)

                            VStack(alignment: .leading, spacing: 20) {
                                HStack(spacing: 5) {
                                    Text("Price type:")
                                        .font(.semiBold(size: 19))
                                        .foregroundColor(.customText2)
                                        .multilineTextAlignment(.leading)
                                        .frame(width: 98, alignment: .leading)

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
                                                    .background(Capsule().stroke(Color.customAccent1, lineWidth: 2))
                                            }
                                            .onTapGesture {
                                                self.priceType = priceType
                                            }
                                    }
                                    Spacer()
                                }

                                HStack(spacing: 5) {
                                    Text("Fee type:")
                                        .font(.semiBold(size: 19))
                                        .foregroundColor(.customText2)
                                        .multilineTextAlignment(.leading)
                                        .frame(width: 98, alignment: .leading)

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
                                                    .background(Capsule().stroke(Color.customAccent1, lineWidth: 2))
                                            }
                                            .onTapGesture {
                                                self.feeType = feeType
                                            }
                                    }
                                    Spacer()
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
                                .padding(.top, 3)
                                .padding(.bottom, -5)
                                .onTapGesture {
                                    refreshPrices(fetchMode: .forcedRefresh)
                                }
//                                RoundedButton<EmptyView>(text: "refresh prices",
//                                              width: 100,
//                                              height: 30,
//                                              maxSize: nil,
//                                              fontSize: 16,
//                                              color: Color.customOrange,
//                                              borderColor: Color.clear,
//                                              textColor: Color.customWhite,
//                                              padding: 10,
//                                              accessoryView: nil) {
//
//                                }

                                HStack(spacing: 10) {
                                    Text("Size")
                                        .font(.semiBold(size: 16))
                                        .foregroundColor(.customText2)
                                        .frame(maxWidth: 90)
                                    ForEach(store.state.settings.displayedStores.compactMap { Store.store(withId: $0) }) { store in
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
                                    Spacer()
                                }
                                .padding(5)

                                if loader.isLoading {
                                    CustomSpinner(text: "Loading...", animate: true)
                                        .padding(5)
                                }

                                if let preferredSize = store.state.settings.preferredShoeSize,
                                   item?.sortedSizes.contains(preferredSize) == true,
                                   let row = item?.priceRow(size: preferredSize,
                                                            priceType: priceType,
                                                            feeType: feeType,
                                                            stores: store.state.settings.displayedStores) {
                                    Text("Your size:")
                                        .font(.semiBold(size: 14))
                                        .foregroundColor(.customText1)
                                        .padding(.top, -5)
                                        .padding(.bottom, -10)
                                    priceRow(row: row)
                                    Text("All sizes:")
                                        .font(.semiBold(size: 14))
                                        .foregroundColor(.customText1)
                                        .padding(.bottom, -10)
                                }
                                ForEach((item?.allPriceRows(priceType: priceType, feeType: feeType, stores: store.state.settings.displayedStores)) ??
                                    []) { (row: Item.PriceRow) in
                                        priceRow(row: row)
                                }
                            }
                        }
                        .withDefaultPadding(padding: .horizontal)
                        .padding(.vertical, 10)
                        .padding(.bottom, 127)
                    }

                    .onAppear { scrollViewProxy.scrollTo(0) }
                }
            }
            .if(item != nil) {
                $0
                    .withFloatingButton(button: NextButton(text: "Add to Inventory",
                                                           size: .init(width: 260, height: 60),
                                                           color: .customBlack,
                                                           tapped: {
                                                               addToInventory = (true, nil)
                                                               addedInventoryItem = false
                                                           })
                            .disabled(loader.isLoading)
                            .centeredHorizontally()
                            .padding(.top, 20))
            }
            .withSnackBar(text: "Added to inventory", shouldShow: $showSnackBar)
            .navigationbarHidden()
            .onAppear {
                if firstShow {
                    firstShow = false
                    updateItem(newItem: store.state.selectedItem)
                    refreshPrices(fetchMode: .cacheOrRefresh)
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

    private func refreshPrices(fetchMode: FetchMode) {
        store.send(.main(action: .getItemDetails(item: item, itemId: itemId, fetchMode: fetchMode)), completed: loader.getLoader())
    }

    private func updateItem(newItem: Item?) {
        guard let newItem = newItem, newItem.id == itemId else { return }
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
                              itemId: "GHVDY45") {}
    }
}
