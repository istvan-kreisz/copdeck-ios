//
//  StackView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/15/21.
//

import SwiftUI
import Combine

struct StackView: View {
    var stack: Stack
    @Binding var searchText: String
    @Binding var inventoryItems: [InventoryItem]
    @Binding var selectedInventoryItemId: String?
    @Binding var isEditing: Bool
    @Binding var selectedInventoryItems: [InventoryItem]
    @Binding var isSelected: Bool
    @Binding var bestPrices: [String: PriceWithCurrency]
    let requestInfo: [ScraperRequestInfo]
    var didTapEditStack: (() -> Void)?

    var allStackItems: [InventoryItem] {
        stack.inventoryItems(allInventoryItems: inventoryItems).filter { $0.name.lowercased().fuzzyMatch(searchText.lowercased()) }
    }

    var body: some View {
        VStack {
            Text("\(allStackItems.count) \(searchText.isEmpty ? "Items:" : "Results:")")
                .foregroundColor(.customText1)
                .font(.bold(size: 12))
                .leftAligned()
                .padding(.horizontal, 28)
            VerticalListView(bottomPadding: 130) {
                ForEach(allStackItems) { inventoryItem in
                    InventoryListItem(inventoryItem: inventoryItem,
                                      bestPrice: bestPrices[inventoryItem.id],
                                      selectedInventoryItemId: $selectedInventoryItemId,
                                      isSelected: selectedInventoryItems.contains(where: { $0.id == inventoryItem.id }),
                                      isEditing: $isEditing,
                                      requestInfo: requestInfo) {
                            if selectedInventoryItems.contains(where: { $0.id == inventoryItem.id }) {
                                selectedInventoryItems = selectedInventoryItems.filter { $0.id != inventoryItem.id }
                            } else {
                                selectedInventoryItems.append(inventoryItem)
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
