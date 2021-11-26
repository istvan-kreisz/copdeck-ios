//
//  StackSummaryListItem.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/1/21.
//

import SwiftUI

struct StackSummaryListItem: View {
    var inventoryItem: InventoryItem
    @Binding var selectedInventoryItem: InventoryItem?

    func priceStack() -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text("Price".uppercased())
                .foregroundColor(.customText2)
                .font(.bold(size: 9))
            Text(inventoryItem.copdeckPrice?.price.asString ?? "-")
                .foregroundColor(.customText1)
                .font(.bold(size: 20))
        }
    }

    var body: some View {
        VerticalListItem(itemId: inventoryItem.itemId ?? "",
                         title: inventoryItem.name,
                         source: imageSource(for: inventoryItem),
                         flipImage: inventoryItem.imageURL?.store?.id == .klekt,
                         isEditing: .constant(false),
                         isSelected: false,
                         ribbons: inventoryItem.tags.filter { $0.id == "sold" }.map { ($0.name, $0.color) },
                         addShadow: false,
                         accessoryView1: InventoryViewPills(inventoryItem: inventoryItem, inventoryItemDetails: [.condition, .size]).leftAligned(),
                         accessoryView2: priceStack(),
                         onTapped: { selectedInventoryItem = inventoryItem })
    }
}
