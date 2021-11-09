//
//  SelectStackItemsListItem.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/15/21.
//

import SwiftUI

struct SelectStackItemsListItem: View {
    var inventoryItem: InventoryItem
    @Binding var isSelected: Bool

    var body: some View {
        VerticalListItemWithAccessoryView1(itemId: inventoryItem.itemId ?? "",
                                           title: inventoryItem.name,
                                           source: imageSource(for: inventoryItem),
                                           flipImage: inventoryItem.imageURL?.store?.id == .klekt,
                                           isEditing: .constant(false),
                                           isSelected: isSelected,
                                           selectionStyle: .highlight,
                                           ribbons: inventoryItem.tags.first(n: 2).map { ($0.name, $0.color) },
                                           accessoryView: InventoryViewPills(inventoryItem: inventoryItem).leftAligned(),
                                           onTapped: { isSelected.toggle() })
    }
}
