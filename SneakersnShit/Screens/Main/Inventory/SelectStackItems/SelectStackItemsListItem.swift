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
    var requestInfo: [ScraperRequestInfo]

    var body: some View {
        VerticalListItemWithAccessoryView1(title: inventoryItem.name,
                                           imageURL: inventoryItem.imageURL,
                                           flipImage: inventoryItem.imageURL?.store.id == .klekt,
                                           requestInfo: requestInfo,
                                           isEditing: .constant(false),
                                           isSelected: isSelected,
                                           selectionStyle: .highlight,
                                           accessoryView: InventoryViewPills(inventoryItem: inventoryItem).leftAligned()) {
                isSelected.toggle()
        }
    }
}
