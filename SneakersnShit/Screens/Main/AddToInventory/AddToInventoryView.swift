//
//  AddToInventoryView.swift
//  CopDeck
//
//  Created by István Kreisz on 7/14/21.
//

import SwiftUI

struct AddToInventoryView: View {
    let currency: Currency
    let sortedSizes: [ItemType: [String]]
    let sizesConverted: [ItemType: [String]]

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
    @State var updateSignal = 0

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
        self._styleId = State(initialValue: item?.styleId ?? "")
        self._notes = State(initialValue: "")

        let isValidSize = item.map { i in presented.wrappedValue.size.map { i.sortedSizes.contains($0) } ?? false } ?? false
        let inventoryItem1: InventoryItem
        if let item = item {
            inventoryItem1 = InventoryItem(fromItem: item, size: isValidSize ? presented.wrappedValue.size : nil)
        } else {
            inventoryItem1 = InventoryItem.new
        }
        self._inventoryItem1 = State(initialValue: inventoryItem1)
        let sortedSizes = inventoryItem1.sortedSizes
        self.sortedSizes = sortedSizes
        var sizesConverted = sortedSizes
        sizesConverted[.shoe] = sizesConverted[.shoe]?.asSizes(of: inventoryItem1)
        self.sizesConverted = sizesConverted

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
        VerticalListView(bottomPadding: 0, spacing: 8, addHorizontalPadding: true, listRowStyling: .color(.customBackground)) {
            VStack(spacing: 20) {
                ItemImageViewWithNavBar(itemId: item?.id,
                                        source: item.map { imageSource(for: $0) },
                                        shouldDismiss: { presented = (false, nil) },
                                        flipImage: item?.imageURL?.store?.id == .klekt)
                    .cornerRadius(Styles.cornerRadius)

                Text("Add To Inventory")
                    .font(.bold(size: 30))
                    .foregroundColor(.customText1)
                    .padding(.bottom, 8)
            }

            TextFieldRounded(title: "name",
                             placeHolder: "name",
                             style: .white,
                             text: $name,
                             addClearButton: true)
            if item?.isShoe == true {
                TextFieldRounded(title: "styleid",
                                 placeHolder: "styleid",
                                 style: .white,
                                 text: item?.isShoe == true ? $styleId : .constant("-"),
                                 width: 200,
                                 addClearButton: true)
                    .leftAligned()
            }

            NewItemCard(inventoryItem: $inventoryItem1,
                        tags: $tags,
                        updateSignal: $updateSignal,
                        purchasePrice: priceWithCurrency,
                        currency: currency,
                        sortedSizes: sortedSizes,
                        sizesConverted: sizesConverted,
                        showCopDeckPrice: false,
                        highlightCopDeckPrice: false,
                        addQuantitySelector: true,
                        didTapAddTag: {
                            showAddNewTagPopup = true
                        }, didTapDeleteTag: didTapDeleteTag)
            if inventoryItem2 != nil {
                NewItemCard(inventoryItem: .init($inventoryItem2, replacingNilWith: .empty),
                            tags: $tags,
                            updateSignal: $updateSignal,
                            purchasePrice: priceWithCurrency,
                            currency: currency,
                            sortedSizes: sortedSizes,
                            sizesConverted: sizesConverted,
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
                            }, didTapDeleteTag: didTapDeleteTag)
            }
            if inventoryItem3 != nil {
                NewItemCard(inventoryItem: .init($inventoryItem3, replacingNilWith: .empty),
                            tags: $tags,
                            updateSignal: $updateSignal,
                            purchasePrice: priceWithCurrency,
                            currency: currency,
                            sortedSizes: sortedSizes,
                            sizesConverted: sizesConverted,
                            showCopDeckPrice: false,
                            highlightCopDeckPrice: false,
                            addQuantitySelector: true,
                            didTapDelete: {
                                self.inventoryItem3 = self.inventoryItem4
                                self.inventoryItem4 = self.inventoryItem5
                                self.inventoryItem5 = nil
                            }, didTapAddTag: {
                                showAddNewTagPopup = true
                            }, didTapDeleteTag: didTapDeleteTag)
            }
            if inventoryItem4 != nil {
                NewItemCard(inventoryItem: .init($inventoryItem4, replacingNilWith: .empty),
                            tags: $tags,
                            updateSignal: $updateSignal,
                            purchasePrice: priceWithCurrency,
                            currency: currency,
                            sortedSizes: sortedSizes,
                            sizesConverted: sizesConverted,
                            showCopDeckPrice: false,
                            highlightCopDeckPrice: false,
                            addQuantitySelector: true,
                            didTapDelete: {
                                self.inventoryItem4 = self.inventoryItem5
                                self.inventoryItem5 = nil
                            }, didTapAddTag: {
                                showAddNewTagPopup = true
                            }, didTapDeleteTag: didTapDeleteTag)
            }
            if inventoryItem5 != nil {
                NewItemCard(inventoryItem: .init($inventoryItem5, replacingNilWith: .empty),
                            tags: $tags,
                            updateSignal: $updateSignal,
                            purchasePrice: priceWithCurrency,
                            currency: currency,
                            sortedSizes: sortedSizes,
                            sizesConverted: sizesConverted,
                            showCopDeckPrice: false,
                            highlightCopDeckPrice: false,
                            addQuantitySelector: true,
                            didTapDelete: {
                                self.inventoryItem5 = nil
                            }, didTapAddTag: {
                                showAddNewTagPopup = true
                            }, didTapDeleteTag: didTapDeleteTag)
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

            Group {
                TextFieldRounded(title: "notes",
                                 placeHolder: "add any notes here",
                                 style: .white,
                                 text: $notes,
                                 addClearButton: true)
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
        }
        .background(Color.customBackground
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all))
        .hideKeyboardOnScroll()
        .withPopup {
            NewTagPopup(isShowing: $showAddNewTagPopup) { name, color in
                let newTag = Tag(name: name, color: color)
                AppStore.default.send(.main(action: .addNewTag(tag: newTag)))
                self.tags.append(newTag)
            }
        }
        .navigationbarHidden()
    }

    private func didTapDeleteTag(tag: Tag) {
        AppStore.default.send(.main(action: .deleteTag(tag: tag)))
        self.tags.removeAll(where: { $0.id == tag.id })
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
        updateSignal += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let inventoryItems = allInventoryItems
                .compactMap { $0 }
                .flatMap { inventoryItem -> [InventoryItem] in
                    Array.init(repeating: 0, count: inventoryItem.count).map { _ in
                        var copy = inventoryItem.copy(withName: name, styleId: styleId, notes: notes)
                        copy.id = UUID().uuidString
                        return copy
                    }
                }
            AppStore.default.send(.main(action: .addToInventory(inventoryItems: inventoryItems)))
            presented = (false, nil)
            addedInvantoryItem = true
        }
    }
}
