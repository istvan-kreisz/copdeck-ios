//
//  StackView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/15/21.
//

import SwiftUI
import Combine

struct StackView: View {
    @EnvironmentObject var store: AppStore

    @Binding var searchText: String
    @Binding var inventoryItems: [InventoryItemWrapper]
    @Binding var selectedInventoryItemId: String?
    @Binding var isEditing: Bool
    @Binding var selectedInventoryItems: [InventoryItem]
    @Binding var isSelected: Bool
    var didTapEditStack: (() -> Void)?

    var allItems: [InventoryItemWrapper] {
        inventoryItems.filter { $0.inventoryItem.name.lowercased().fuzzyMatch(searchText.lowercased()) }
    }

    var body: some View {
        VStack {
            Text("\(inventoryItems.count) \(searchText.isEmpty ? "Items:" : "Results:")")
                .foregroundColor(.customText1)
                .font(.bold(size: 12))
                .leftAligned()
                .padding(.horizontal, 28)
            VerticalListView(bottomPadding: 130) {
                ForEach(allItems) { inventoryItem in
                    InventoryListItem(inventoryItem: inventoryItem.inventoryItem,
                                      bestPrice: inventoryItem.bestPrice,
                                      selectedInventoryItemId: $selectedInventoryItemId,
                                      isSelected: selectedInventoryItems.contains(where: { $0.id == inventoryItem.id }),
                                      isEditing: $isEditing,
                                      requestInfo: store.state.requestInfo) {
                            if selectedInventoryItems.contains(where: { $0.id == inventoryItem.id }) {
                                selectedInventoryItems = selectedInventoryItems.filter { $0.id != inventoryItem.id }
                            } else {
                                selectedInventoryItems.append(inventoryItem.inventoryItem)
                            }
                    }
                }
                .padding(.vertical, 6)

                if let didTapEditStack = didTapEditStack {
                    AccessoryButton(title: "Add / Delete Items",
                                    color: .customBlue,
                                    textColor: .customBlue,
                                    width: 170,
                                    imageName: "plus",
                                    tapped: didTapEditStack)
                        .leftAligned()
                        .padding(.top, 3)
                }
            }
        }
    }
}
