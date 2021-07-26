//
//  InventoryListItem.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct InventoryListItem: View {
    var inventoryItem: InventoryItem
    @Binding var selectedInventoryItemId: String?

    @Binding var isEditing: Bool
    var isSelected: Bool
    var onSelectorTapped: () -> Void

    var body: some View {
        ListItem(title: inventoryItem.name,
                 imageURL: inventoryItem.imageURL ?? "",
                 isEditing: $isEditing,
                 isSelected: isSelected,
                 accessoryView: InventoryViewPills(inventoryItem: inventoryItem).leftAligned()) {
                selectedInventoryItemId = inventoryItem.id
        } onSelectorTapped: {
            onSelectorTapped()
        }
    }
}

struct InventoryListItem_Previews: PreviewProvider {
    static var previews: some View {
        return ListItem<EmptyView>(title: "yooo",
                                   imageURL: "https://images.stockx.com/images/Adidas-Yeezy-Boost-350-V2-Core-Black-Red-2017-Product.jpg?fit=fill&bg=FFFFFF&w=700&h=500&auto=format,compress&trim=color&q=90&dpr=2&updated_at=1606320792",
                                   isEditing: .constant(false),
                                   isSelected: false,
                                   onTapped: {})
    }
}
