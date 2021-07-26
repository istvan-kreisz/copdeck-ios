//
//  InventoryViewPills.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct InventoryViewPills: View {
    var inventoryItem: InventoryItem
    var details: [String] {
        [inventoryItem.condition.rawValue,
         inventoryItem.size,
         inventoryItem.purchasePrice.map { "$\($0)" }]
            .compactMap { $0 }
    }

    var body: some View {
        HStack {
            ForEach(Array(details.enumerated()), id: \.self.1) { detail in
                PillView(title: detail.element, color: Color.pillColors[detail.offset % Color.pillColors.count])
            }
        }
    }
}

struct InventoryViewPills_Previews: PreviewProvider {
    static var previews: some View {
        return InventoryViewPills(inventoryItem: .init(fromItem: Item.sample))
    }
}
