//
//  InventoryListItem.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct InventoryListItem: View {
    var inventoryItem: InventoryItem
    let priceName: String?
    let bestPrice: ListingPrice?
    @Binding var selectedInventoryItem: InventoryItem?
    var isSelected: Bool
    let isInSharedStack: Bool

    @Binding var isEditing: Bool
    var requestInfo: [ScraperRequestInfo]
    var onSelectorTapped: () -> Void

    func bestPriceStack() -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text(priceName?.uppercased() ?? "")
                .foregroundColor(.customText2)
                .font(.bold(size: 9))
            Text(bestPrice?.price.asString ?? "-")
                .foregroundColor(.customText1)
                .font(.bold(size: 20))
            if let storeId = bestPrice?.storeId, let store = Store.store(withId: storeId) {
                Text("(\(store.name.rawValue))")
                    .foregroundColor(.customText2)
                    .font(.medium(size: 12))
            }
        }
    }

    var body: some View {
        VStack(spacing: 3) {
            if isInSharedStack && inventoryItem.copdeckPrice == nil {
                HStack(spacing: 2) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.medium(size: 12))
                        .foregroundColor(.customRed)
                    Text("Missing CopDeck price")
                        .font(.medium(size: 12))
                        .foregroundColor(.customRed)
                    Spacer()
                }
            }
            VerticalListItem(itemId: inventoryItem.itemId ?? "",
                             title: inventoryItem.name,
                             source: imageSource(for: inventoryItem),
                             flipImage: inventoryItem.imageURL?.store?.id == .klekt,
                             requestInfo: requestInfo,
                             isEditing: $isEditing,
                             isSelected: isSelected,
                             ribbonText: inventoryItem.status == .Sold ? "Sold" : nil,
                             accessoryView1: InventoryViewPills(inventoryItem: inventoryItem).leftAligned(),
                             accessoryView2: bestPriceStack()) {
                selectedInventoryItem = inventoryItem
            } onSelectorTapped: {
                onSelectorTapped()
            }
        }
    }
}
