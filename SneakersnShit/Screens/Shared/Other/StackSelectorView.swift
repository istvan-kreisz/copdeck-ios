//
//  StackSelectorView.swift
//  CopDeck
//
//  Created by István Kreisz on 11/25/21.
//

import Foundation
import SwiftUI

struct StackSelectorView: View {
    var title: String
    var color: Color
    @Binding var isSelected: Bool
    
    static let height: CGFloat = 30
    static let cornerRadius: CGFloat = 8

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.semiBold(size: 13))
                .foregroundColor(isSelected ? Color.customWhite : Color.customText1)
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.bold(size: 10))
                    .foregroundColor(.customWhite)
            }
        }
        .padding(.horizontal, 9)
        .frame(height: Self.height)
        .cornerRadius(Self.cornerRadius)
        .background(isSelected ? RoundedRectangle(cornerRadius: Self.cornerRadius).fill(color) : RoundedRectangle(cornerRadius: Self.cornerRadius).fill(.clear))
        .overlay(RoundedRectangle(cornerRadius: Self.cornerRadius).stroke(color, lineWidth: 2))
        .fixedSize(horizontal: true, vertical: true)
        .onTapGesture {
            isSelected.toggle()
        }
    }
}

