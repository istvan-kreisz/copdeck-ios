//
//  HorizontalListItemSquare.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/2/21.
//

import SwiftUI

import SwiftUI

struct HorizontalListItemSquare: View {
    var title: String
    var imageURL: ImageURL?
    var flipImage = false
    var requestInfo: [ScraperRequestInfo]
    var index: Int

    var onTapped: () -> Void

    static let size: CGFloat = 62

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Styles.cornerRadius)
                .fill(Color.customWhite)
                .frame(width: Self.size, height: Self.size)
                .background(RoundedRectangle(cornerRadius: Styles.cornerRadius)
                    .stroke(Color.pillColors[index % Color.pillColors.count], lineWidth: 4)
                    .background(Color.clear))
                .withDefaultShadow()

            ItemImageView(withImageURL: imageURL,
                          requestInfo: requestInfo,
                          size: Self.size * 0.66,
                          aspectRatio: nil,
                          flipImage: flipImage)
                .padding(.horizontal, 12)
                .frame(width: Self.size - 2, height: Self.size - 2)
                .cornerRadius(Self.size / 2)
                .onTapGesture(perform: onTapped)
        }
        .frame(width: Self.size, height: Self.size)
        
    }
}
