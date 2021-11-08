//
//  HorizontalListItemRound.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct HorizontalListItemRound: View {
    let itemId: String
    var title: String
    let source: ImageViewSourceType
    var flipImage = false
    var index: Int

    var onTapped: () -> Void

    static let size: CGFloat = 62

    var body: some View {
        ItemImageView(itemId: itemId,
                      source: source,
                      size: Self.size * 0.66,
                      aspectRatio: nil,
                      flipImage: flipImage)
            .padding(.horizontal, 12)
            .frame(width: Self.size, height: Self.size)
            .background(Circle()
                .stroke(Color.pillColors[index % Color.pillColors.count], lineWidth: 4)
                .background(Color.customWhite))
            .cornerRadius(Self.size / 2)
            .withDefaultShadow()
            .onTapGesture(perform: onTapped)
    }
}
