//
//  InventoryListItem.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct InventoryListItem: View {
    var inventoryItem: InventoryItem
    @Binding var bestPrice: PriceWithCurrency?
    @Binding var selectedInventoryItemId: String?
    var isSelected: Bool

    @Binding var isEditing: Bool
    var requestInfo: [ScraperRequestInfo]
    var onSelectorTapped: () -> Void

    func bestPriceStack() -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text("Best price".uppercased())
                .foregroundColor(.customText2)
                .font(.bold(size: 9))
            Text(bestPrice.map { "\($0.currencySymbol.rawValue)\($0.price.rounded(toPlaces: 0))" } ?? "-")
                .foregroundColor(.customText1)
                .font(.bold(size: 20))
        }
    }

    var body: some View {
        VerticalListItem(title: inventoryItem.name,
                         imageURL: inventoryItem.imageURL,
                         flipImage: inventoryItem.imageURL?.store.id == .klekt,
                         requestInfo: requestInfo,
                         isEditing: $isEditing,
                         isSelected: isSelected,
                         accessoryView1: InventoryViewPills(inventoryItem: inventoryItem).leftAligned(),
                         accessoryView2: bestPriceStack()) {
                selectedInventoryItemId = inventoryItem.id
        } onSelectorTapped: {
            onSelectorTapped()
        }
    }
}

struct InventoryListItem_Previews: PreviewProvider {
    static var previews: some View {
        return VerticalListItem<EmptyView, EmptyView>(title: "yooo",
                                                      imageURL: nil,
                                                      requestInfo: [],
                                                      isEditing: .constant(false),
                                                      isSelected: false,
                                                      onTapped: {})
    }
}
