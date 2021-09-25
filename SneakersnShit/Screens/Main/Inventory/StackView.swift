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
    @Binding var selectedInventoryItem: InventoryItem?
    @Binding var isEditing: Bool
    @Binding var showFilters: Bool
    @Binding var selectedInventoryItems: [InventoryItem]
    @Binding var isSelected: Bool
    @Binding var bestPrices: [String: PriceWithCurrency]
    let requestInfo: [ScraperRequestInfo]
    var didTapEditStack: (() -> Void)?
    var didTapShareStack: (() -> Void)?
    var didTapAddItems: (() -> Void)?

    var allStackItems: [InventoryItem] {
        let sortedItems = stack.inventoryItems(allInventoryItems: inventoryItems, filters: filters, searchText: searchText)
            .sorted { item1, item2 in
                switch filters.sortOption {
                case .CreatedDesc:
                    return (item1.created ?? 0) > (item2.created ?? 0)
                case .CreatedAsc:
                    return (item1.created ?? 0) < (item2.created ?? 0)
                case .UpdatedDesc:
                    return (item1.updated ?? 0) > (item2.updated ?? 0)
                case .UpdatedAsc:
                    return (item1.updated ?? 0) < (item2.updated ?? 0)
                }
            }
        if filters.groupByModels {
            var items: [InventoryItem] = []
            sortedItems.forEach { item in
                if let firstIndex = items.firstIndex(where: { $0.itemId == item.itemId }) {
                    items.insert(item, at: firstIndex)
                } else {
                    items.append(item)
                }
            }
            return items
        } else {
            return sortedItems
        }
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
                AccessoryButton(title: "Quick Edit",
                                color: .customPurple,
                                textColor: .customPurple,
                                width: nil,
                                imageName: "plus",
                                tapped: { isEditing.toggle() })
                    .buttonStyle(PlainButtonStyle())
                    .layoutPriority(1)
                if let didTapEditStack = didTapEditStack {
                    AccessoryButton(title: "Stack Details",
                                    color: .customBlue,
                                    textColor: .customBlue,
                                    width: nil,
                                    imageName: "chevron.right",
                                    tapped: didTapEditStack)
                        .buttonStyle(PlainButtonStyle())
                        .layoutPriority(1)
                    if let didTapShareStack = didTapShareStack {
                        AccessoryButton(title: "Share Stack",
                                        color: .customOrange,
                                        textColor: .customOrange,
                                        width: nil,
                                        imageName: "arrowshape.turn.up.right.fill",
                                        tapped: didTapShareStack)
                            .buttonStyle(PlainButtonStyle())
                            .layoutPriority(1)
                    }
                }
                Spacer()
            }
        }
        .padding(.bottom, 5)
    }

    var body: some View {
        toolbar()
        if let didTapAddItems = didTapAddItems, allStackItems.isEmpty {
            EmptyStateButton(title: "Your stack is empty", buttonTitle: "Start adding items", style: .large, showPlusIcon: true, action: didTapAddItems)
                .padding(.top, 50)
        } else {
            ForEach(allStackItems) { (inventoryItem: InventoryItem) in
                InventoryListItem(inventoryItem: inventoryItem,
                                  bestPrice: bestPrices[inventoryItem.id],
                                  selectedInventoryItem: $selectedInventoryItem,
                                  isSelected: selectedInventoryItems.contains(where: { $0.id == inventoryItem.id }),
                                  isEditing: $isEditing,
                                  requestInfo: requestInfo) {
                        if selectedInventoryItems.contains(where: { $0.id == inventoryItem.id }) {
                            selectedInventoryItems = selectedInventoryItems.filter { $0.id != inventoryItem.id }
                        } else {
                            selectedInventoryItems.append(inventoryItem)
                        }
                }
                .id(inventoryItem.id)
            }
            .padding(.vertical, 2)
        }
    }
}
