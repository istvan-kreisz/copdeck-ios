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
    let requestInfo: [ScraperRequestInfo]
    let size: CGFloat
    let aspectRatio: CGFloat?
    let flipImage: Bool
    let showPlaceholder: Bool
    let resizingMode: ImageResizingMode

    init(itemId: String,
         source: ImageViewSourceType,
         requestInfo: [ScraperRequestInfo],
         size: CGFloat,
         aspectRatio: CGFloat?,
         flipImage: Bool = false,
         showPlaceholder: Bool = true,
         resizingMode: ImageResizingMode = .aspectFit) {
        self.itemId = itemId
        self.source = source
        self.requestInfo = requestInfo
        self.size = size
        self.aspectRatio = aspectRatio
        self.flipImage = flipImage
        self.showPlaceholder = showPlaceholder
        self.resizingMode = resizingMode
    }

    var body: some View {
        ImageView(source: source, size: size, aspectRatio: aspectRatio, flipImage: flipImage, showPlaceholder: showPlaceholder, resizingMode: resizingMode) {
            AppStore.default.send(.main(action: .uploadItemImage(itemId: itemId, image: $0)), debounceDelayMs: 1000)
        }
    }
}
