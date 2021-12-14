//
//  StackView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/15/21.
//

import SwiftUI
import Combine

struct StackView: View {
    struct EmptyStateConfig {
        let title: String
        let buttonTitle: String
        let action: (() -> Void)
    }
    var stack: Stack
    let isContentLocked: Bool
    @Binding var searchText: String
    @Binding var filters: Filters
    @Binding var inventoryItems: [InventoryItem]
    @Binding var selectedInventoryItem: InventoryItem?
    @Binding var isEditing: Bool
    @Binding var showFilters: Bool
    @Binding var selectedInventoryItems: [InventoryItem]
    @Binding var isSelected: Bool
    let emptyStateConfig: EmptyStateConfig
    var didTapEditStack: (() -> Void)?
    var didTapShareStack: (() -> Void)?

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
                                 placeHolder: didTapEditStack == nil ? "Search your inventory" : "Search your stack",
                                 style: .white,
                                 text: $searchText,
                                 addClearButton: true)
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
                        AccessoryButton(title: "Share",
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
        if allStackItems.isEmpty {
            EmptyStateButton(title: searchText.isEmpty ? emptyStateConfig.title : "No search results",
                             buttonTitle: searchText.isEmpty ? emptyStateConfig.buttonTitle : nil,
                             style: .large,
                             showPlusIcon: true,
                             isContentLocked: false,
                             action: emptyStateConfig.action)
                .padding(.top, 50)
        } else {
            ForEach(allStackItems) { (inventoryItem: InventoryItem) in
                InventoryListItem(inventoryItem: inventoryItem,
                                  priceName: "Best Price",
                                  isContentLocked: isContentLocked,
                                  bestPrice: inventoryItem.itemFields.bestPrice,
                                  selectedInventoryItem: $selectedInventoryItem,
                                  isSelected: selectedInventoryItems.contains(where: { $0.id == inventoryItem.id }),
                                  isInSharedStack: false,
                                  isEditing: $isEditing) {
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
