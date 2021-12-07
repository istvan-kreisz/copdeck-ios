//
//  GridSelectorMenu.swift
//  CopDeck
//
//  Created by István Kreisz on 11/9/21.
//

import Foundation
import SwiftUI

struct GridSelectorMenu: View {
    static let cornerRadius: CGFloat = 7
    static let itemWidth: CGFloat = 47

    @Binding var selectedItem: String
    var options: [String]
    var style: NewItemCard.Style = .card

    var items: [GridItem] {
        Array(repeating: GridItem(.flexible(minimum: Self.itemWidth)), count: UIScreen.isSmallScreen ? 5 : 6)
    }

    var body: some View {
        LazyVGrid(columns: items, spacing: 10) {
            ForEach(options.uniqued(), id: \.self) { option in
                Text(option)
                    .font(.semiBold(size: 16))
                    .foregroundColor(Color.customText1)
                    .frame(width: Self.itemWidth, height: Self.itemWidth)
                    .background(style == .card ? Color.customAccent4 : Color.customWhite)
                    .cornerRadius(Self.cornerRadius)
                    .overlay(RoundedRectangle(cornerRadius: Self.cornerRadius)
                        .stroke(option == selectedItem ? Color.customBlue : Color.clear, lineWidth: 2)
                        .background((option == selectedItem ? Color.customBlue.opacity(0.1) : Color.clear).cornerRadius(Self.cornerRadius)))
                    .onTapGesture {
                        selectedItem = option
                    }
            }
            .id(UUID())
        }
        .id(UUID())
    }
}
