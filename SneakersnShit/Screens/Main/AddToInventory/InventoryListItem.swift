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
    var isSelected: Bool

    @Binding var isEditing: Bool
    var requestInfo: [ScraperRequestInfo]
    var onSelectorTapped: () -> Void

    var body: some View {
        ListItem(title: inventoryItem.name,
                 imageURL: inventoryItem.imageURL,
                 flipImage: inventoryItem.imageURL?.store.id == .klekt,
                 requestInfo: requestInfo,
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
                                   imageURL: nil,
                                   requestInfo: [],
                                   isEditing: .constant(false),
                                   isSelected: false,
                                   onTapped: {})
    }
}
