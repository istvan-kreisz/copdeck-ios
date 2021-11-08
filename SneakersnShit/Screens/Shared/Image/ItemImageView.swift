//
//  ItemImageView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/28/21.
//

import SwiftUI
import NukeUI
import Nuke

struct ItemImageView: View {
    let itemId: String
    let source: ImageViewSourceType
    let size: CGFloat
    let aspectRatio: CGFloat?
    let flipImage: Bool
    let showPlaceholder: Bool
    let resizingMode: ImageResizingMode

    init(itemId: String,
         source: ImageViewSourceType,
         size: CGFloat,
         aspectRatio: CGFloat?,
         flipImage: Bool = false,
         showPlaceholder: Bool = true,
         resizingMode: ImageResizingMode = .aspectFit) {
        self.itemId = itemId
        self.source = source
        self.size = size
        self.aspectRatio = aspectRatio
        self.flipImage = flipImage
        self.showPlaceholder = showPlaceholder
        self.resizingMode = resizingMode
    }

    var body: some View {
        ImageView(source: source, size: size, aspectRatio: aspectRatio, flipImage: flipImage, showPlaceholder: showPlaceholder, resizingMode: resizingMode) { image, imageURL in
            if imageURL?.contains("images.stockx") == true || imageURL?.contains("image.goat") == true {
                AppStore.default.send(.main(action: .uploadItemImage(itemId: itemId, image: image)), debounceDelayMs: 1000)
            }
        }
    }
}
