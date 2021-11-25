//
//  ColorSelectorMenu.swift
//  CopDeck
//
//  Created by István Kreisz on 11/9/21.
//

import Foundation
import SwiftUI

struct ColorSelectorMenu: View {
    static let itemWidth: CGFloat = 30
    @Binding var color: String
    var colors = Tag.allColors

    static let smallRadius: CGFloat = 25
    static let largeRadius: CGFloat = 35

    var items: [GridItem] {
        Array(repeating: GridItem(.flexible(minimum: Self.itemWidth)), count: Tag.allColors.count)
    }

    var body: some View {
        LazyVGrid(columns: items, spacing: 10) {
            ForEach(colors.uniqued(), id: \.self) { color in
                ZStack(alignment: .center) {
                    Circle().fill(Tag.color(color))
                        .frame(width: Self.smallRadius, height: Self.smallRadius)
                    if self.color == color {
                        Circle().fill(Tag.color(color))
                            .frame(width: Self.largeRadius, height: Self.largeRadius)
                        Image(systemName: "checkmark")
                            .font(.bold(size: 16))
                            .foregroundColor(.customWhite)
                    } else {
                        Circle().stroke(Color.customAccent2, lineWidth: 2)
                            .frame(width: Self.largeRadius, height: Self.largeRadius)
                    }
                }
                .onTapGesture {
                    self.color = color
                }
            }
        }
    }
}
