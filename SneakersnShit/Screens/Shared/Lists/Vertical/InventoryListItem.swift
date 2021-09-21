//
//  InventoryListItem.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct InventoryListItem: View {
    var inventoryItem: InventoryItem
    let bestPrice: PriceWithCurrency?
    @Binding var selectedInventoryItem: InventoryItem?
    var isSelected: Bool

    @Binding var isEditing: Bool
    var requestInfo: [ScraperRequestInfo]
    var onSelectorTapped: () -> Void

    func bestPriceStack() -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text("Best price".uppercased())
                .foregroundColor(.customText2)
                .font(.bold(size: 9))
            Text(bestPrice?.asString ?? "-")
                .foregroundColor(.customText1)
                .font(.bold(size: 20))
        }
    }

    var body: some View {
        VerticalListItem(itemId: inventoryItem.id ?? "",
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
