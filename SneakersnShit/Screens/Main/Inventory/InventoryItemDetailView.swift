//
//  InventoryItemDetailView.swift
//  CopDeck
//
//  Created by István Kreisz on 3/30/21.
//

import SwiftUI

struct InventoryItemDetailView: View {
    @EnvironmentObject var store: AppStore
    @State var inventoryItem: InventoryItem
    @Binding var isEditingInventoryItem: Bool

    @State var name: String
    @State var styleId: String
    @State var notes: String

    init(inventoryItem: InventoryItem, isEditingInventoryItem: Binding<Bool>) {
        self._inventoryItem = State(initialValue: inventoryItem)
        self._isEditingInventoryItem = isEditingInventoryItem

        self._name = State(initialValue: inventoryItem.name)
        self._styleId = State(initialValue: inventoryItem.itemId ?? "")
        self._notes = State(initialValue: inventoryItem.notes ?? "")
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center, spacing: 20) {
                ItemImageViewWithNavBar(imageURL: inventoryItem.imageURL)

                VStack(alignment: .center, spacing: 8) {
                    Text("Edit Item")
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

                    NewItemCard(inventoryItem: $inventoryItem, purchasePrice: inventoryItem.purchasePrice, style: .noBackground)

                    TextFieldRounded(title: "notes (optional)",
                                     placeHolder: "add any notes here",
                                     style: .white,
                                     size: .large,
                                     text: $notes)
                        .padding(.top, 15)

                    HStack(spacing: 10) {
                        RoundedButton(text: "Delete item",
                                      size: .init(width: 180, height: 60),
                                      maxSize: nil,
                                      color: .clear,
                                      borderColor: .customRed,
                                      textColor: .customRed,
                                      accessoryView: nil,
                                      tapped: { deleteInventoryItem() })

                        RoundedButton(text: "Save changes",
                                      size: .init(width: 180, height: 60),
                                      maxSize: nil,
                                      color: .customBlack,
                                      accessoryView: nil,
                                      tapped: { updateInventoryItem() })
                    }
                    .padding(.top, 40)
                }
                .padding(.horizontal, 28)
                .padding(.top, 14)
                .padding(.bottom, 20)
                .background(Color.customBackground
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all))
            }
        }
        .onAppear {
            store.send(.main(action: .setSelectedItem(item: nil)))
            store.send(.main(action: .getItemDetails(item: nil, itemId: inventoryItem.id, forced: false)))
        }
        .navigationbarHidden()
    }

    private func deleteInventoryItem() {
        #warning("yo")
    }

    private func updateInventoryItem() {
        #warning("yo")
//        store.send(.main(action: .addToInventory(inventoryItems: inventoryItems)))
        isEditingInventoryItem = false
    }
}

struct InventoryItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        return InventoryItemDetailView(inventoryItem: .init(fromItem: .sample), isEditingInventoryItem: .constant(true))
    }
}
