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
    @Binding var filters: Filters
    @Binding var inventoryItems: [InventoryItem]
    @Binding var selectedInventoryItemId: String?
    @Binding var isEditing: Bool
    @Binding var showFilters: Bool
    @Binding var selectedInventoryItems: [InventoryItem]
    @Binding var isSelected: Bool
    @Binding var bestPrices: [String: PriceWithCurrency]
    let requestInfo: [ScraperRequestInfo]
    var didTapEditStack: (() -> Void)?
    var didTapShareStack: (() -> Void)?

    var allStackItems: [InventoryItem] {
        stack.inventoryItems(allInventoryItems: inventoryItems, filters: filters, searchText: searchText)
    }

    func toolbar() -> some View {
        VStack {
            HStack(alignment: .center, spacing: 13) {
                TextFieldRounded(title: nil,
                                 placeHolder: "Search your inventory",
                                 style: .white,
                                 text: $searchText)
                Button(action: {
                    showFilters = true
                }, label: {
                    ZStack {
                        Circle()
                            .fill(Color.customOrange)
                            .frame(width: 32, height: 32)
                        Image("filter")
                            .renderingMode(.template)
                            .frame(height: 24)
                            .foregroundColor(.customWhite)
                    }
                })
            }
            .padding(.top, 2)

            HStack(spacing: 8) {
                AccessoryButton(title: "Edit Items",
                                color: .customPurple,
                                textColor: .customPurple,
                                width: nil,
                                imageName: "plus",
                                tapped: { isEditing.toggle() })
                    .buttonStyle(PlainButtonStyle())
                if let didTapEditStack = didTapEditStack {
                    AccessoryButton(title: "Edit Stack",
                                    color: .customBlue,
                                    textColor: .customBlue,
                                    width: nil,
                                    imageName: "chevron.right",
                                    tapped: didTapEditStack)
                        .buttonStyle(PlainButtonStyle())
                    if let didTapShareStack = didTapShareStack {
                        AccessoryButton(title: "Share Stack",
                                        color: .customOrange,
                                        textColor: .customOrange,
                                        width: nil,
                                        imageName: "arrowshape.turn.up.right.fill",
                                        tapped: didTapShareStack)
                            .buttonStyle(PlainButtonStyle())
                    }
                }
                Spacer()
            }
            .padding(.top, 3)
        }
        .withDefaultPadding(padding: .horizontal)
        .padding(.bottom, 5)
    }

    var body: some View {
        VerticalListView(bottomPadding: 130, toolbar: toolbar()) {
            ForEach(allStackItems) { (inventoryItem: InventoryItem) in
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
        }
    }
}
