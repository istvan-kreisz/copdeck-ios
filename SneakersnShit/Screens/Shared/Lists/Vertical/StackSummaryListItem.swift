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
    var requestInfo: [ScraperRequestInfo]

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
        VerticalListItem(title: inventoryItem.name,
                         source: imageSource(for: inventoryItem),
                         flipImage: inventoryItem.imageURL?.store?.id == .klekt,
                         requestInfo: requestInfo,
                         isEditing: .constant(false),
                         isSelected: false,
                         ribbonText: inventoryItem.status == .Sold ? "Sold" : nil,
                         addShadow: false,
                         accessoryView1: InventoryViewPills(inventoryItem: inventoryItem, pillTypes: [.condition, .size]).leftAligned(),
                         accessoryView2: priceStack(),
                         onTapped: { selectedInventoryItem = inventoryItem })
    }
}
