//
//  AddToInventoryView.swift
//  CopDeck
//
//  Created by István Kreisz on 7/14/21.
//

import SwiftUI

struct AddToInventoryView: View {
    @EnvironmentObject var store: AppStore
    @State var item: Item
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

    var allInventoryItems: [InventoryItem?] { [inventoryItem1,
                                               inventoryItem2,
                                               inventoryItem3,
                                               inventoryItem4,
                                               inventoryItem5] }

    private var itemCount: Int {
        allInventoryItems.compactMap { $0 }.count
    }

    init(item: Item, presented: Binding<(isActive: Bool, size: String?)>, addedInvantoryItem: Binding<Bool>) {
        self._item = State(initialValue: item)
        self._presented = presented
        self._addedInvantoryItem = addedInvantoryItem

        self._name = State(initialValue: item.name ?? "")
        self._styleId = State(initialValue: item.bestStoreInfo?.sku ?? "")
        self._notes = State(initialValue: "")

        self._inventoryItem1 = State(initialValue: InventoryItem(fromItem: item, size: presented.wrappedValue.size))
        self._inventoryItem2 = State(initialValue: nil)
        self._inventoryItem3 = State(initialValue: nil)
        self._inventoryItem4 = State(initialValue: nil)
        self._inventoryItem5 = State(initialValue: nil)
    }

    var priceWithCurrency: PriceWithCurrency? {
        item.retailPrice.asPriceWithCurrency(currency: store.state.settings.currency)
    }

    var body: some View {
        let isPresented = Binding<Bool>(get: { presented.isActive },
                                        set: { presented = $0 ? presented : (false, nil) })
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center, spacing: 20) {
                ItemImageViewWithNavBar(showView: isPresented,
                                        imageURL: item.imageURL,
                                        requestInfo: store.state.requestInfo)

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

                    NewItemCard(inventoryItem: $inventoryItem1, purchasePrice: priceWithCurrency, currency: store.state.currency)
                    if let inventoryItem2 = inventoryItem2 {
                        let item = Binding<InventoryItem>(get: { inventoryItem2 }, set: { self.inventoryItem2 = $0 })
                        NewItemCard(inventoryItem: item, purchasePrice: priceWithCurrency, currency: store.state.currency)
                    }
                    if let inventoryItem3 = inventoryItem3 {
                        let item = Binding<InventoryItem>(get: { inventoryItem3 }, set: { self.inventoryItem3 = $0 })
                        NewItemCard(inventoryItem: item, purchasePrice: priceWithCurrency, currency: store.state.currency)
                    }
                    if let inventoryItem4 = inventoryItem4 {
                        let item = Binding<InventoryItem>(get: { inventoryItem4 }, set: { self.inventoryItem4 = $0 })
                        NewItemCard(inventoryItem: item, purchasePrice: priceWithCurrency, currency: store.state.currency)
                    }
                    if let inventoryItem5 = inventoryItem5 {
                        let item = Binding<InventoryItem>(get: { inventoryItem5 }, set: { self.inventoryItem5 = $0 })
                        NewItemCard(inventoryItem: item, purchasePrice: priceWithCurrency, currency: store.state.currency)
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
                                     size: .large,
                                     text: $notes)
                        .padding(.top, 15)

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
                .padding(.horizontal, Styles.horizontalPadding)
                .padding(.top, 14)
                .padding(.bottom, 20)
                .background(Color.customBackground
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all))
            }
        }
        .navigationbarHidden()
    }

    private func addMore() {
        if inventoryItem2 == nil {
            inventoryItem2 = InventoryItem(fromItem: item, size: inventoryItem1.size)
        } else if inventoryItem3 == nil {
            inventoryItem3 = InventoryItem(fromItem: item, size: inventoryItem2?.size)
        } else if inventoryItem4 == nil {
            inventoryItem4 = InventoryItem(fromItem: item, size: inventoryItem3?.size)
        } else if inventoryItem5 == nil {
            inventoryItem5 = InventoryItem(fromItem: item, size: inventoryItem4?.size)
        }
    }

    private func addItems() {
        let inventoryItems = allInventoryItems
            .compactMap { $0 }
            .map { inventoryItem -> InventoryItem in
                inventoryItem.copy(withName: name, itemId: styleId, notes: notes)
            }
        store.send(.main(action: .addToInventory(inventoryItems: inventoryItems)))
        presented = (false, nil)
        addedInvantoryItem = true
    }
}

struct AddToInventoryView_Previews: PreviewProvider {
    static var previews: some View {
        return AddToInventoryView(item: Item.sample, presented: .constant((true, nil)), addedInvantoryItem: .constant(false))
    }
}
