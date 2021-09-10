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
    var shouldDismiss: () -> Void

    @State var name: String
    @State var styleId: String
    @State var notes: String

    @State var showItemDetails = false

    var item: Item? {
        guard let itemId = inventoryItem.itemId,
              let item = ItemCache.default.value(itemId: itemId, settings: .default)
        else {
            return nil
        }
        return item
    }

    var imageDownloadHeaders: [String: String] {
        if let imageURLStoreId = inventoryItem.imageURL?.store?.id, let requestInfo = store.state.requestInfo(for: imageURLStoreId) {
            return requestInfo.imageDownloadHeaders
        } else {
            return [:]
        }
    }

    init(inventoryItem: InventoryItem, shouldDismiss: @escaping () -> Void) {
        self._inventoryItem = State(initialValue: inventoryItem)
        self.shouldDismiss = shouldDismiss

        self._name = State(initialValue: inventoryItem.name)
        self._styleId = State(initialValue: inventoryItem.itemId ?? "")
        self._notes = State(initialValue: inventoryItem.notes ?? "")
    }

    var body: some View {
        VStack {
            NavigationLink(destination: inventoryItem.itemId.map { (itemId: String) in
                ItemDetailView(item: nil,
                               itemId: itemId,
                               favoritedItemIds: store.state.favoritedItems.map(\.id)) {
                        showItemDetails = false
                }
            },
            isActive: $showItemDetails) { EmptyView() }

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 20) {
                    ItemImageViewWithNavBar(imageURL: inventoryItem.imageURL, requestInfo: [], shouldDismiss: shouldDismiss)

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

                        NewItemCard(inventoryItem: $inventoryItem,
                                    purchasePrice: inventoryItem.purchasePrice,
                                    currency: Currency(code: .usd, symbol: .usd),
                                    style: NewItemCard.Style.noBackground,
                                    sizes: item?.sortedSizes ?? ALLSHOESIZES)

//                        VStack(alignment: .leading, spacing: 9) {
//                            Text("Photos:".uppercased())
//                                .font(.bold(size: 12))
//                                .foregroundColor(.customText2)
//                                .leftAligned()
//
//                            if inventoryItem.photos.isEmpty {
//                                EmptyStateButton(title: "Your haven't added any photos", buttonTitle: "Start adding photos", style: .regular, showPlusIcon: false) {
//
//                                }
//                                .padding(.vertical, 20)
//                            } else {
//                                AccessoryButton(title: "Add Photos",
//                                                color: .customBlue,
//                                                textColor: .customBlue,
//                                                width: 170,
//                                                imageName: "plus",
//                                                tapped: {
//    //                                                    showItemSelector = true
//                                                })
//                                    .leftAligned()
//                                    .padding(.top, 5)
//                            }
//                        }
//                        .asCard()
//                        .padding(.top, 15)

                        TextFieldRounded(title: "notes (optional)",
                                         placeHolder: "add any notes here",
                                         style: .white,
                                         text: $notes)
                            .padding(.top, 11)

                        HStack(spacing: 10) {
                            RoundedButton<EmptyView>(text: "Delete item",
                                                     width: 180,
                                                     height: 60,
                                                     maxSize: CGSize(width: (UIScreen.screenWidth - Styles.horizontalMargin * 2 - 10) / 2,
                                                                     height: UIScreen.isSmallScreen ? 50 : 60),
                                                     fontSize: UIScreen.isSmallScreen ? 14 : 16,
                                                     color: .clear,
                                                     borderColor: .customRed,
                                                     textColor: .customRed,
                                                     accessoryView: nil,
                                                     tapped: { deleteInventoryItem() })

                            RoundedButton<EmptyView>(text: "Save changes",
                                                     width: 180,
                                                     height: 60,
                                                     maxSize: CGSize(width: (UIScreen.screenWidth - Styles.horizontalMargin * 2 - 10) / 2,
                                                                     height: UIScreen.isSmallScreen ? 50 : 60),
                                                     fontSize: UIScreen.isSmallScreen ? 14 : 16,
                                                     color: .customBlack,
                                                     accessoryView: nil,
                                                     tapped: { updateInventoryItem() })
                        }
                        .padding(.top, 40)
                    }
                    .padding(.horizontal, Styles.horizontalMargin)
                    .padding(.top, 14)
                    .padding(.bottom, 20)
                    .background(Color.customBackground
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all))
                }
            }
            .navigationbarHidden()
        }
    }

    private func deleteInventoryItem() {
        store.send(.main(action: .removeFromInventory(inventoryItems: [inventoryItem])))
        shouldDismiss()
    }

    private func updateInventoryItem() {
        let updatedInventoryItem = inventoryItem.copy(withName: name, itemId: styleId, notes: notes)
        store.send(.main(action: .updateInventoryItem(inventoryItem: updatedInventoryItem)))
        shouldDismiss()
    }
}

struct InventoryItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        return InventoryItemDetailView(inventoryItem: .init(fromItem: .sample)) {}
    }
}
