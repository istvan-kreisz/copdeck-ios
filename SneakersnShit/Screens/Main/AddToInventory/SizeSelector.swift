//
//  SizeSelector.swift
//  CopDeck
//
//  Created by István Kreisz on 12/6/21.
//

import SwiftUI

struct SizeSelector: View {
    static let padding: CGFloat = 3

    let style: NewItemCard.Style
    let sortedSizes: [ItemType: [String]]
    let sizesConverted: [ItemType: [String]]

    @Binding var itemType: ItemType
    @Binding var selectedSize: String

    var toggleButtonStyle: ToggleButton.Style {
        style == .card ? .gray : .white
    }

    var body: some View {
        let type = Binding<String>(get: { itemType.rawValue },
                                   set: { newValue in
                                       let newType = ItemType(rawValue: newValue.lowercased()) ?? .shoe
                                       itemType = newType
                                       selectedSize = sortedSizes[newType]?.first ?? ""
                                   })
        ToggleButton(title: "size",
                     selection: type,
                     options: ItemType.allCases.map(\.rawValue),
                     style: toggleButtonStyle)

        if let sizesArray = sizesConverted[itemType] {
            let size = Binding<String>(get: { selectedSize }, set: { selectedSize = $0 })

            GridSelectorMenu(selectedItem: size, options: sizesArray, style: style)
        }
    }
}
