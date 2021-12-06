//
//  TagView.swift
//  CopDeck
//
//  Created by István Kreisz on 11/9/21.
//

import Foundation
import SwiftUI

struct TagView: View {
    var title: String
    var color: Color
    @Binding var isSelected: Bool
    var deleteTag: () -> Void
    
    static let height: CGFloat = 22

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
        .cornerRadius(Self.height / 2)
        .background(isSelected ? Capsule().fill(color) : Capsule().fill(.clear))
        .overlay(Capsule().stroke(color, lineWidth: 2))
        .fixedSize(horizontal: true, vertical: true)
        .onTapGesture {
            isSelected.toggle()
        }
        .contextMenu {
            Button("Delete tag", action: deleteTag)
        }
    }
}
