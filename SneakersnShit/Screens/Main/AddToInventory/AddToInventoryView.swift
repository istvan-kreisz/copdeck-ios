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
    @Binding var addToInventory: Bool

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

    init(item: Item, addToInventory: Binding<Bool>) {
        self._item = State(initialValue: item)
        self._addToInventory = addToInventory

        self._name = State(initialValue: item.name ?? "")
        self._styleId = State(initialValue: item.bestStoreInfo?.sku ?? "")
        self._notes = State(initialValue: "")

        self._inventoryItem1 = State(initialValue: InventoryItem(fromItem: item))
        self._inventoryItem2 = State(initialValue: nil)
        self._inventoryItem3 = State(initialValue: nil)
        self._inventoryItem4 = State(initialValue: nil)
        self._inventoryItem5 = State(initialValue: nil)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center, spacing: 20) {
                ItemImageViewWithNavBar(imageURL: item.imageURL)

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

                    NewItemCard(inventoryItem: $inventoryItem1, purchasePrice: item.retailPrice)
                    if let inventoryItem2 = inventoryItem2 {
                        let item = Binding<InventoryItem>(get: { inventoryItem2 }, set: { self.inventoryItem2 = $0 })
                        NewItemCard(inventoryItem: item, purchasePrice: self.item.retailPrice)
                    }
                    if let inventoryItem3 = inventoryItem3 {
                        let item = Binding<InventoryItem>(get: { inventoryItem3 }, set: { self.inventoryItem3 = $0 })
                        NewItemCard(inventoryItem: item, purchasePrice: self.item.retailPrice)
                    }
                    if let inventoryItem4 = inventoryItem4 {
                        let item = Binding<InventoryItem>(get: { inventoryItem4 }, set: { self.inventoryItem4 = $0 })
                        NewItemCard(inventoryItem: item, purchasePrice: self.item.retailPrice)
                    }
                    if let inventoryItem5 = inventoryItem5 {
                        let item = Binding<InventoryItem>(get: { inventoryItem5 }, set: { self.inventoryItem5 = $0 })
                        NewItemCard(inventoryItem: item, purchasePrice: self.item.retailPrice)
                    }
                    if itemCount != allInventoryItems.count {
                        AccessoryButton(title: "Add More", color: .customBlue, textColor: .customBlue, width: 110, tapped: addMore)
                            .leftAligned()
                    }

                    TextFieldRounded(title: "notes (optional)",
                                     placeHolder: "add any notes here",
                                     style: .white,
                                     size: .large,
                                     text: $notes)
                        .padding(.top, 15)

                    RoundedButton(text: "Add \(itemCount) item\(itemCount == 1 ? "" : "s")",
                                  size: .init(width: 145, height: 60),
                                  maxSize: nil,
                                  color: .customBlack,
                                  accessoryView: nil,
                                  tapped: { addItems() })
                        .centeredHorizontally()
                        .padding(.top, 15)
                }
                .padding(.horizontal, 28)
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
            inventoryItem2 = InventoryItem(fromItem: item)
        } else if inventoryItem3 == nil {
            inventoryItem3 = InventoryItem(fromItem: item)
        } else if inventoryItem4 == nil {
            inventoryItem4 = InventoryItem(fromItem: item)
        } else if inventoryItem5 == nil {
            inventoryItem5 = InventoryItem(fromItem: item)
        }
    }

    private func addItems() {
        let inventoryItems = allInventoryItems
            .compactMap { $0 }
            .map { inventoryItem -> InventoryItem in
                inventoryItem.copy(withName: name, itemId: styleId, notes: notes)
            }
        store.send(.main(action: .addToInventory(inventoryItems: inventoryItems)))
        addToInventory = false
    }
}

struct AddToInventoryView_Previews: PreviewProvider {
    static var previews: some View {
        return AddToInventoryView(item: Item.sample, addToInventory: .constant(true))
    }
}
