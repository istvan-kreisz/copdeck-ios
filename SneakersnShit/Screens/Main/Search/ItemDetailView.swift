//
//  ItemDetailView.swift
//  CopDeck
//
//  Created by István Kreisz on 3/28/21.
//

import SwiftUI
import Combine
import Firebase

struct ItemDetailView: View {
    @EnvironmentObject var store: DerivedGlobalStore
    @State private var item: Item?
    @State private var priceType: PriceType = .Ask
    @State private var feeType: FeeType = .None

    @State private var addToInventory: (isActive: Bool, size: String?) = (false, nil)
    @State private var addedInventoryItem = false
    @State private var firstShow = true
    @State var showSnackBar = false
    @State var isFavorited: Bool
    @State var showPopup = false
    @State var itemListener: DocumentListener<Item>?

    @State private var restocksPriceType: Item.StorePrice.StoreInventoryItem.RestocksPriceType = .regular
    @State private var goatPriceType: Item.StorePrice.StoreInventoryItem.GOATPriceType = .regular
    @State private var isInDamagedBox: Bool? = nil

    var shouldDismiss: () -> Void

    private let itemId: String
    private let styleId: String

    enum BorderStyle {
        case red, green, regular
    }

    @StateObject private var loader = Loader()

    init(item: ItemSearchResult?, itemId: String, styleId: String, favoritedItemIds: [String], shouldDismiss: @escaping () -> Void) {
        self._item = State(initialValue: item.map { withCalculatedPrices(item: .init(from: $0)) })
        self.itemId = itemId
        self.styleId = styleId
        self.shouldDismiss = shouldDismiss
        self._isFavorited = State<Bool>(initialValue: favoritedItemIds.contains(itemId))
    }

    private func priceTypeToggle(store: StoreId) -> some View {
        Button {
            if store == .restocks {
                restocksPriceType = restocksPriceType == .regular ? .consign : .regular
            } else if store == .goat {
                goatPriceType = goatPriceType == .regular ? .instant : .regular
            }
        } label: {
            let text1 = store == .restocks ? restocksPriceType.name : goatPriceType.name
            let text2 = store == .restocks ? restocksPriceType.reversed.name : goatPriceType.reversed.name
            VStack(alignment: .center, spacing: 1) {
                Text(text1)
                    .font(.bold(size: 12))
                    .foregroundColor(.customBlue)
                Image(systemName: "arrow.up.arrow.down")
                    .font(.semiBold(size: 7))
                    .foregroundColor(.customText2)
                Text(text2)
                    .font(.regular(size: 10))
                    .foregroundColor(.customText2)
            }
        }
    }

    private func priceRow(row: Item.PriceRow) -> some View {
        HStack(spacing: 10) {
            Button(action: {
                addToInventory = (true, row.size)
            }) {
                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
                    Text(item?.isShoe == true ? row.size.asSize(of: item) : row.size)
                        .font(.semiBold(size: 15))
                        .padding(.trailing, 3)
                        .frame(height: 32)
                        .frame(maxWidth: 50)
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

            ForEach(row.prices) { (price: Item.PriceRow.Price) in
                let overlayColor: Color = (price.store.id == row.lowest?.id && (feeType == .Buy || feeType == .None)) ? .customGreen :
                    (price.store.id == row.highest?.id && (feeType == .Sell || feeType == .None) ? .customRed : .customAccent1)
                Text(price.primaryText)
                    .font(.regular(size: 18))
                    .foregroundColor(.customText1)
                    .frame(height: 32)
                    .frame(maxWidth: .infinity)
                    .overlay(Capsule().stroke(overlayColor, lineWidth: 2))
                    .onTapGesture {
                        var link: String?
                        switch feeType {
                        case .Buy:
                            link = price.buyLink
                        case .Sell:
                            link = price.sellLink
                        case .None:
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

    var body: some View {
        ZStack {
            Color.customWhite.edgesIgnoringSafeArea(.all)
            let isAddToInventoryActive = Binding<Bool>(get: { addToInventory.isActive },
                                                       set: { addToInventory = $0 ? addToInventory : (false, nil) })
            let isFavorited = Binding<Bool>(get: { self.isFavorited }, set: { _ in self.didToggleFavorite() })

            NavigationLink(destination: item
                .map { item in AddToInventoryView(item: item,
                                                  currency: store.globalState.settings.currency,
                                                  presented: $addToInventory,
                                                  addedInvantoryItem: $addedInventoryItem) } ?? nil,
                isActive: isAddToInventoryActive) { EmptyView() }

            ScrollView(.vertical, showsIndicators: false) {
                ScrollViewReader { scrollViewProxy in
                    VStack(alignment: .center, spacing: 20) {
                        ItemImageViewWithNavBar(itemId: item?.id ?? "",
                                                source: imageSource(for: item),
                                                shouldDismiss: shouldDismiss,
                                                isFavorited: isFavorited,
                                                flipImage: item?.imageURL?.store?.id == .klekt)

                        ZStack {
                            Color.customBackground.edgesIgnoringSafeArea(.all)
                            VStack(alignment: .leading, spacing: 8) {
                                CopiableText(item?.bestStoreInfo?.brand.uppercased())
                                    .font(.bold(size: 12))
                                    .foregroundColor(.customText2)

                                CopiableText(item?.bestStoreInfo?.name)
                                    .font(.bold(size: 30))
                                    .foregroundColor(.customText1)
                                    .padding(.bottom, 8)

                                HStack(spacing: 10) {
                                    Spacer()
                                    VStack(spacing: 2) {
                                        CopiableText(item?.isShoe == true && item?.styleId?.contains("_") == false ? item?.styleId : nil, defaultIfNil: "-")
                                            .font(.bold(size: 20))
                                            .foregroundColor(.customText1)
                                        Text("Style ID")
                                            .font(.regular(size: 15))
                                            .foregroundColor(.customText2)
                                    }
                                    Spacer()
                                    VStack(spacing: 2) {
                                        CopiableText(item?.bestStoreInfo?.retailPrice
                                            .map { "\(USD.symbol.rawValue)\($0.rounded(toPlaces: 1))" })
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
                            .padding(.horizontal, 10)

                            VStack(alignment: .leading, spacing: 20) {
                                VStack(alignment: .leading, spacing: 20) {
                                    HStack(spacing: 5) {
                                        Text("Price type")
                                            .font(.semiBold(size: 19))
                                            .foregroundColor(.customText2)
                                            .multilineTextAlignment(.leading)
                                            .frame(width: 98, alignment: .leading)

                                        ForEach(PriceType.allCases) { (priceType: PriceType) in
                                            Text(priceType.rawValue.capitalized)
                                                .frame(width: 60, height: 31)
                                                .foregroundColor(priceType == self.priceType ? Color.customWhite : Color.customText1)
                                                .background(Capsule().fill(priceType == self.priceType ? Color.customBlue : Color.clear))
                                                .background(Capsule().stroke(priceType == self.priceType ? Color.clear : Color.customBlue, lineWidth: 2))
                                                .onTapGesture {
                                                    self.priceType = priceType
                                                }
                                        }
                                        Spacer()
                                    }

                                    HStack(spacing: 5) {
                                        HStack(spacing: 5) {
                                            Text("Fee type")
                                                .font(.semiBold(size: 19))
                                                .foregroundColor(.customText2)
                                                .multilineTextAlignment(.leading)
                                            Button {
                                                showPopup = true
                                            } label: {
                                                Image(systemName: "questionmark.circle.fill")
                                                    .font(.regular(size: 15))
                                                    .foregroundColor(.customText2)
                                            }
                                        }
                                        .frame(width: 98, alignment: .leading)

                                        ForEach(FeeType.allCases) { (feeType: FeeType) in
                                            Text(feeType.rawValue.capitalized)
                                                .frame(width: 60, height: 31)
                                                .foregroundColor(feeType == self.feeType ? Color.customWhite : Color.customText1)
                                                .background(Capsule().fill(feeType == self.feeType ? Color.customPurple : Color.clear))
                                                .background(Capsule().stroke(feeType == self.feeType ? Color.clear : Color.customPurple, lineWidth: 2))
                                                .onTapGesture {
                                                    self.feeType = feeType
                                                }
                                        }
                                        Spacer()
                                    }
                                    .padding(.top, -10)

                                    if store.globalState.canViewPrices {
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
                                            refreshPrices(forced: true)
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)

                                VStack(alignment: .leading, spacing: 20) {
                                    HStack(alignment: .top, spacing: 5) {
                                        Text("Size\n(\(AppStore.default.state.settings.shoeSize.rawValue))")
                                            .font(.semiBold(size: 15))
                                            .lineLimit(2)
                                            .foregroundColor(.customText2)
                                            .frame(height: 36)
                                            .frame(maxWidth: 50)

                                        ForEach(store.globalState.displayedStores.compactMap { Store.store(withId: $0) }) { (store: Store) in
                                            VStack(alignment: .center, spacing: 5) {
                                                Text(store.name.rawValue)
                                                    .font(.bold(size: 16))
                                                    .foregroundColor(.customText1)
                                                    .frame(maxWidth: .infinity)
                                                    .onTapGesture {
                                                        if let link = item?.storeInfo.first(where: { $0.store.id == store.id })?.url,
                                                           let url = URL(string: link) {
                                                            UIApplication.shared.open(url)
                                                        }
                                                    }
                                                if store.id == .restocks || store.id == .goat {
                                                    priceTypeToggle(store: store.id)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.bottom, -15)

                                    if loader.isLoading && store.globalState.canViewPrices {
                                        CustomSpinner(text: "Refreshing prices...", fontSize: 15, animate: true)
                                            .padding(5)
                                    }

                                    if store.globalState.canViewPrices {
                                        VStack(spacing: 20) {
                                            if let preferredSize = store.globalState.settings.preferredShoeSize,
                                               item?.itemTypeDefaulted == .shoe,
                                               item?.sortedSizes.contains(where: { $0 == preferredSize }) == true,
                                               let row = item?.priceRow(size: preferredSize,
                                                                        priceType: priceType,
                                                                        feeType: feeType,
                                                                        stores: store.globalState.displayedStores,
                                                                        restocksPriceType: restocksPriceType,
                                                                        goatPriceType: goatPriceType,
                                                                        isInDamagedBox: isInDamagedBox) {
                                                Text("Your size:")
                                                    .font(.semiBold(size: 14))
                                                    .foregroundColor(.customText1)
                                                    .padding(.bottom, -10)
                                                    .leftAligned()
                                                priceRow(row: row)
                                                Text("All sizes:")
                                                    .font(.semiBold(size: 14))
                                                    .foregroundColor(.customText1)
                                                    .padding(.bottom, -10)
                                                    .leftAligned()
                                            }
                                            ForEach((item?.allPriceRows(priceType: priceType,
                                                                        feeType: feeType,
                                                                        stores: store.globalState.displayedStores,
                                                                        restocksPriceType: restocksPriceType,
                                                                        goatPriceType: goatPriceType,
                                                                        isInDamagedBox: isInDamagedBox)) ?? []) { (row: Item.PriceRow) in
                                                priceRow(row: row)
                                            }
                                            .id(0)
                                        }
                                    } else {
                                        Text("")
                                            .padding(.top, 50)
                                            .frame(width: UIScreen.screenWidth - Styles.horizontalPadding * 2)
                                            .lockedContent(displayStyle: .hideOriginal,
                                                           contentSttyle: .text(text: "You've reached your free price check limit, start your free trial to get unlimited access!",
                                                                                size: 15, color: .customBlue))
                                            .centeredHorizontally()
                                    }
                                }
                                .padding(.horizontal, 10)
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.bottom, 127)
                    }

                    .onAppear { scrollViewProxy.scrollTo(0) }
                }
            }
            .withFloatingButton(button: NextButton(text: "Add to Inventory",
                                                   size: .init(width: 260, height: 60),
                                                   color: .customBlack,
                                                   tapped: {
                                                       addToInventory = (true, store.globalState.settings.preferredShoeSize)
                                                       addedInventoryItem = false
                                                   })
                    .centeredHorizontally()
                    .padding(.top, 20)
                    .opacity(item != nil ? 1.0 : 0.0))
            .withSnackBar(text: "Added to inventory", shouldShow: $showSnackBar)
            .withPopup {
                Popup<EmptyView>(isShowing: $showPopup,
                                 title: "Fee Type",
                                 subtitle: "\"None\" shows you the prices you'd see on the reselling sites.\n\n\"Buy\" adds the buyer fees onto the price so the prices are what you'd see at checkout.\n\n\"Sell\" deducts the seller fees from the price so the prices are what you'd get after selling your item.\n\nIn order to get accurate results with \"Buy\" or \"Sell\" selected, make sure to configure your buyer & seller fees in \"Inventory\" > \"Settings\".",
                                 firstAction: .init(name: "Okay", tapped: { showPopup = false }),
                                 secondAction: nil)
            }
            .onAppear {
                if firstShow {
                    firstShow = false
                    refreshPrices(forced: false)
                    setupItemListener()
                    Analytics.logEvent("visited_item_detail", parameters: ["userId": AppStore.default.state.user?.id ?? ""])
                }
            }
            .onDisappear {
                let pricesLoaded = item?.storePrices.map { $0.inventory.count }.sum() ?? 0 > 0
                if store.globalState.canViewPrices && pricesLoaded {
                    AppStore.default.send(.main(action: .updateLastPriceViews(itemId: itemId)))
                }
                itemListener?.reset()
            }
            .onChange(of: addedInventoryItem) { new in
                if new {
                    showSnackBar = true
                }
            }
            .navigationbarHidden()
        }
    }

    private func refreshPrices(forced: Bool) {
        if store.globalState.canViewPrices {
            let load = loader.getLoader()
            store.send(.main(action: .updateItem(item: item, itemId: itemId, styleId: styleId, forced: forced) { load(.success(())) }))
//            if item?.updated?.isOlderThan(minutes: World.Constants.itemPricesRefreshPeriodMin) == true {
//                shouldUpdateLastPriceViews = true
//            }
        }
    }

    private func setupItemListener() {
        if store.globalState.canViewPrices {
            store.send(.main(action: .getItemListener(itemId: itemId, updated: { item in
                self.set(item: item)
            }, completion: { listener in
                self.itemListener?.reset()
                self.itemListener = listener
            })))
        }
    }

    private func set(item: Item) {
        store.send(.main(action: .updateInventoryItems(associatedWith: item)))
        self.item = withCalculatedPrices(item: item)
        store.send(.main(action: .addRecentlyViewed(item: item)))
    }

    private func didToggleFavorite() {
        guard let item = item else { return }
        AppStore.default.environment.feedbackGenerator.selectionChanged()
        let newValue = !isFavorited
        self.isFavorited = newValue
        if newValue {
            store.send(.main(action: .favorite(item: item)))
        } else {
            store.send(.main(action: .unfavorite(item: item)))
        }
    }

    private func updateLastPriceViews() {
        store.send(.main(action: .updateLastPriceViews(itemId: itemId)))
    }
}
