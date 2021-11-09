//
//  AddToInventoryView.swift
//  CopDeck
//
//  Created by István Kreisz on 7/14/21.
//

import SwiftUI

struct AddToInventoryView: View {
    let currency: Currency
    @State var item: Item?
    @Binding var presented: (isActive: Bool, size: String?)
    @Binding var addedInvantoryItem: Bool

    @State var name: String
    @State var styleId: String
    @State var notes: String

    @State var inventoryItem1: InventoryItem
    @State var inventoryItem2: InventoryItem?
    @State var inventoryItem3: InventoryItem?
    @State var inventoryItem4: InventoryItem?
    @State var inventoryItem5: InventoryItem?

    @State var tags: [Tag]
    @State var showAddNewTagPopup = false

    var allInventoryItems: [InventoryItem?] { [inventoryItem1,
                                               inventoryItem2,
                                               inventoryItem3,
                                               inventoryItem4,
                                               inventoryItem5] }

    private var itemCount: Int {
        allInventoryItems.compactMap { $0 }.count
    }

    init(item: Item?, currency: Currency, presented: Binding<(isActive: Bool, size: String?)>, addedInvantoryItem: Binding<Bool>) {
        self._item = State(initialValue: item)
        self.currency = currency
        self._presented = presented
        self._addedInvantoryItem = addedInvantoryItem

        self._name = State(initialValue: item?.name ?? "")
        self._styleId = State(initialValue: item?.bestStoreInfo?.sku ?? "")
        self._notes = State(initialValue: "")

        let isValidSize = item.map { i in presented.wrappedValue.size.map { i.sortedSizes.contains($0) } ?? false } ?? false
        if let item = item {
            self._inventoryItem1 = State(initialValue: InventoryItem(fromItem: item, size: isValidSize ? presented.wrappedValue.size : nil))
        } else {
            self._inventoryItem1 = State(initialValue: InventoryItem.new)
        }

        self._inventoryItem2 = State(initialValue: nil)
        self._inventoryItem3 = State(initialValue: nil)
        self._inventoryItem4 = State(initialValue: nil)
        self._inventoryItem5 = State(initialValue: nil)

        self._tags = State(initialValue: Tag.defaultTags + (AppStore.default.state.user?.tags ?? []))
    }

    var priceWithCurrency: PriceWithCurrency? {
        item?.retailPrice.asPriceWithCurrency(currency: currency)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center, spacing: 20) {
                ItemImageViewWithNavBar(itemId: item?.id,
                                        source: item.map { imageSource(for: $0) },
                                        shouldDismiss: { presented = (false, nil) },
                                        flipImage: item?.imageURL?.store?.id == .klekt)

                VStack(alignment: .center, spacing: 8) {
                    Text("Add To Inventory")
                        .font(.bold(size: 30))
                        .foregroundColor(.customText1)
                        .padding(.bottom, 8)
                    HStack(spacing: 10) {
                        TextFieldRounded(title: "name",
                                         placeHolder: "name",
                                         style: .white,
                                         text: $name)
                        TextFieldRounded(title: "styleid (optional)",
                                         placeHolder: "styleid",
                                         style: .white,
                                         text: $styleId,
                                         width: 100)
                    }

                    NewItemCard(inventoryItem: $inventoryItem1,
                                tags: $tags,
                                purchasePrice: priceWithCurrency,
                                currency: currency,
                                sizes: self.inventoryItem1.sortedSizes,
                                showCopDeckPrice: false,
                                highlightCopDeckPrice: false,
                                addQuantitySelector: true,
                                didTapAddTag: {
                                    showAddNewTagPopup = true
                                })
                    if let inventoryItem2 = inventoryItem2 {
                        let item = Binding<InventoryItem>(get: { inventoryItem2 }, set: { self.inventoryItem2 = $0 })
                        NewItemCard(inventoryItem: item,
                                    tags: $tags,
                                    purchasePrice: priceWithCurrency,
                                    currency: currency,
                                    sizes: inventoryItem2.sortedSizes,
                                    showCopDeckPrice: false,
                                    highlightCopDeckPrice: false,
                                    addQuantitySelector: true,
                                    didTapDelete: {
                                        self.inventoryItem2 = self.inventoryItem3
                                        self.inventoryItem3 = self.inventoryItem4
                                        self.inventoryItem4 = self.inventoryItem5
                                        self.inventoryItem5 = nil
                                    }, didTapAddTag: {
                                        showAddNewTagPopup = true
                                    })
                    }
                    if let inventoryItem3 = inventoryItem3 {
                        let item = Binding<InventoryItem>(get: { inventoryItem3 }, set: { self.inventoryItem3 = $0 })
                        NewItemCard(inventoryItem: item,
                                    tags: $tags,
                                    purchasePrice: priceWithCurrency,
                                    currency: currency,
                                    sizes: inventoryItem3.sortedSizes,
                                    showCopDeckPrice: false,
                                    highlightCopDeckPrice: false,
                                    addQuantitySelector: true,
                                    didTapDelete: {
                                        self.inventoryItem3 = self.inventoryItem4
                                        self.inventoryItem4 = self.inventoryItem5
                                        self.inventoryItem5 = nil
                                    }, didTapAddTag: {
                                        showAddNewTagPopup = true
                                    })
                    }
                    if let inventoryItem4 = inventoryItem4 {
                        let item = Binding<InventoryItem>(get: { inventoryItem4 }, set: { self.inventoryItem4 = $0 })
                        NewItemCard(inventoryItem: item,
                                    tags: $tags,
                                    purchasePrice: priceWithCurrency,
                                    currency: currency,
                                    sizes: inventoryItem4.sortedSizes,
                                    showCopDeckPrice: false,
                                    highlightCopDeckPrice: false,
                                    addQuantitySelector: true,
                                    didTapDelete: {
                                        self.inventoryItem4 = self.inventoryItem5
                                        self.inventoryItem5 = nil
                                    }, didTapAddTag: {
                                        showAddNewTagPopup = true
                                    })
                    }
                    if let inventoryItem5 = inventoryItem5 {
                        let item = Binding<InventoryItem>(get: { inventoryItem5 }, set: { self.inventoryItem5 = $0 })
                        NewItemCard(inventoryItem: item,
                                    tags: $tags,
                                    purchasePrice: priceWithCurrency,
                                    currency: currency,
                                    sizes: inventoryItem5.sortedSizes,
                                    showCopDeckPrice: false,
                                    highlightCopDeckPrice: false,
                                    addQuantitySelector: true,
                                    didTapDelete: {
                                        self.inventoryItem5 = nil
                                    }, didTapAddTag: {
                                        showAddNewTagPopup = true
                                    })
                    }
                    if itemCount != allInventoryItems.count {
                        AccessoryButton(title: "Add More",
                                        color: .customBlue,
                                        textColor: .customBlue,
                                        width: 110,
                                        imageName: "plus",
                                        tapped: addMore)
                            .leftAligned()
                    }

                    TextFieldRounded(title: "notes (optional)",
                                     placeHolder: "add any notes here",
                                     style: .white,
                                     text: $notes)
                        .padding(.top, 11)

                    RoundedButton<EmptyView>(text: "Add \(itemCount) item\(itemCount == 1 ? "" : "s")",
                                             width: 145,
                                             height: 60,
                                             maxSize: nil,
                                             color: .customBlack,
                                             accessoryView: nil,
                                             tapped: { addItems() })
                        .centeredHorizontally()
                        .padding(.top, 15)
                }
                .padding(.horizontal, Styles.horizontalMargin)
                .padding(.top, 14)
                .padding(.bottom, 20)
                .background(Color.customBackground
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all))
            }
        }
        .withPopup {
            NewTagPopup(isShowing: $showAddNewTagPopup) { name, color in
                let newTag = Tag(name: name, color: color)
                AppStore.default.send(.main(action: .addNewTag(tag: newTag)))
                self.tags.append(newTag)
            }
        }
        .navigationbarHidden()
    }

    private func newInventoryItem(size: String?) -> InventoryItem {
        item.map { InventoryItem(fromItem: $0, size: size) } ?? .new
    }

    private func addMore() {
        if inventoryItem2 == nil {
            inventoryItem2 = newInventoryItem(size: inventoryItem1.size)
        } else if inventoryItem3 == nil {
            inventoryItem3 = newInventoryItem(size: inventoryItem2?.size)
        } else if inventoryItem4 == nil {
            inventoryItem4 = newInventoryItem(size: inventoryItem3?.size)
        } else if inventoryItem5 == nil {
            inventoryItem5 = newInventoryItem(size: inventoryItem4?.size)
        }
    }

    private func addItems() {
        let inventoryItems = allInventoryItems
            .compactMap { $0 }
            .flatMap { inventoryItem -> [InventoryItem] in
                Array.init(repeating: 0, count: inventoryItem.count).map { _ in
                    var copy = inventoryItem.copy(withName: name, itemId: styleId, notes: notes)
                    copy.id = UUID().uuidString
                    return copy
                }
            }
        AppStore.default.send(.main(action: .addToInventory(inventoryItems: inventoryItems)))
        presented = (false, nil)
        addedInvantoryItem = true
    }
}
