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

    @State var showItemDetails = false

    var imageDownloadHeaders: [String: String] {
        if let imageURLStoreId = inventoryItem.imageURL?.store.id, let requestInfo = store.state.requestInfo(for: imageURLStoreId) {
            return requestInfo.imageDownloadHeaders
        } else {
            return [:]
        }
    }

    init(inventoryItem: InventoryItem, isEditingInventoryItem: Binding<Bool>) {
        self._inventoryItem = State(initialValue: inventoryItem)
        self._isEditingInventoryItem = isEditingInventoryItem

        self._name = State(initialValue: inventoryItem.name)
        self._styleId = State(initialValue: inventoryItem.itemId ?? "")
        self._notes = State(initialValue: inventoryItem.notes ?? "")
    }

    var body: some View {
        if let itemId = inventoryItem.itemId {
            NavigationLink(destination: ItemDetailView(item: nil,
                                                       showView: $showItemDetails,
                                                       itemId: itemId,
                                                       showAddToInventoryButton: true),
                           isActive: $showItemDetails) { EmptyView() }
        }

        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center, spacing: 20) {
                ItemImageViewWithNavBar(showView: $isEditingInventoryItem, imageURL: inventoryItem.imageURL, requestInfo: store.state.requestInfo)

                VStack(alignment: .center, spacing: 8) {
                    Text("Edit Item")
                        .font(.bold(size: 30))
                        .foregroundColor(.customText1)
                        .padding(.bottom, 8)

                    if inventoryItem.itemId != nil {
                        AccessoryButton(title: "View Prices",
                                        color: .customAccent1,
                                        textColor: .customText1,
                                        width: 125,
                                        imageName: "chevron.right",
                                        buttonPosition: .right,
                                        tapped: { showItemDetails = true })
                    }

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
                    .padding(.top, 15)

                    NewItemCard(inventoryItem: $inventoryItem, purchasePrice: inventoryItem.purchasePrice, currency: store.state.currency, style: .noBackground)

                    TextFieldRounded(title: "notes (optional)",
                                     placeHolder: "add any notes here",
                                     style: .white,
                                     size: .large,
                                     text: $notes)
                        .padding(.top, 15)

                    HStack(spacing: 10) {
                        RoundedButton(text: "Delete item",
                                      size: .init(width: 180, height: 60),
                                      maxSize: CGSize(width: (UIScreen.screenWidth - Styles.horizontalPadding * 2 - 10) / 2, height: UIScreen.isSmallScreen ? 50 : 60),
                                      fontSize: UIScreen.isSmallScreen ? 14 : 16,
                                      color: .clear,
                                      borderColor: .customRed,
                                      textColor: .customRed,
                                      accessoryView: nil,
                                      tapped: { deleteInventoryItem() })

                        RoundedButton(text: "Save changes",
                                      size: .init(width: 180, height: 60),
                                      maxSize: CGSize(width: (UIScreen.screenWidth - Styles.horizontalPadding * 2 - 10) / 2, height: UIScreen.isSmallScreen ? 50 : 60),
                                      fontSize: UIScreen.isSmallScreen ? 14 : 16,
                                      color: .customBlack,
                                      accessoryView: nil,
                                      tapped: { updateInventoryItem() })
                    }
                    .padding(.top, 40)
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

    private func deleteInventoryItem() {
        store.send(.main(action: .removeFromInventory(inventoryItems: [inventoryItem])))
        isEditingInventoryItem = false
    }

    private func updateInventoryItem() {
        let updatedInventoryItem = inventoryItem.copy(withName: name, itemId: styleId, notes: notes)
        store.send(.main(action: .addToInventory(inventoryItems: [updatedInventoryItem])))
        isEditingInventoryItem = false
    }
}

struct InventoryItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        return InventoryItemDetailView(inventoryItem: .init(fromItem: .sample), isEditingInventoryItem: .constant(true))
    }
}
