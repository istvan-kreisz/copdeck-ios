//
//  ItemImageViewWithNavBar.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct ItemImageViewWithNavBar: View {
    let itemId: String?
    let source: ImageViewSourceType?
    var shouldDismiss: () -> Void
    var isFavorited: Binding<Bool>?
    let flipImage: Bool

    let size = UIScreen.main.bounds.width - 80

    var body: some View {
        ZStack {
            Color.customWhite.edgesIgnoringSafeArea(.all)

            if let itemId = itemId, let source = source {
                Color.clear
                    .frame(width: size, height: size)

                ItemImageView(itemId: itemId,
                              source: source,
                              size: size,
                              aspectRatio: nil,
                              flipImage: flipImage,
                              showPlaceholder: false)
            }

            if let isFavorited = isFavorited {
                Button {
                    isFavorited.wrappedValue.toggle()
                } label: {
                    Image(systemName: isFavorited.wrappedValue ? "heart.fill" : "heart")
                        .font(.regular(size: size / 10))
                        .foregroundColor(isFavorited.wrappedValue ? Color.customRed : Color.customAccent1)
                }
                .rightAligned()
                .bottomAligned()
                .padding(.trailing, 20)
            }
            NavigationBar(title: nil, isBackButtonVisible: true, style: .dark, shouldDismiss: shouldDismiss)
                .withDefaultPadding(padding: [.horizontal, .top])
                .topAligned()
        }
    }
}
