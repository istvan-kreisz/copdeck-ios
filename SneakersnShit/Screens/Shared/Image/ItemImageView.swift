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
    let imageURL: ImageURL?
    let requestInfo: [ScraperRequestInfo]
    let size: CGFloat
    let aspectRatio: CGFloat?
    let flipImage: Bool
    let showPlaceholder: Bool
    let isFavorited: Binding<Bool>?

    init(withImageURL imageURL: ImageURL?,
         requestInfo: [ScraperRequestInfo],
         size: CGFloat,
         aspectRatio: CGFloat?,
         flipImage: Bool = false,
         showPlaceholder: Bool = true,
         isFavorited: Binding<Bool>? = nil) {
        self.imageURL = imageURL
        self.requestInfo = requestInfo
        self.size = size
        self.aspectRatio = aspectRatio
        self.flipImage = flipImage
        self.showPlaceholder = showPlaceholder
        self.isFavorited = isFavorited
    }

    var request: ImageRequestConvertible {
        if let imageURL = imageURL, let headers = requestInfo.first(where: { $0.storeId == imageURL.store.id })?.imageDownloadHeaders,
           let url = URL(string: imageURL.url) {
            var request = URLRequest(url: url)
            headers.forEach { name, value in
                request.setValue(value, forHTTPHeaderField: name)
            }
            return ImageRequest(urlRequest: request)
        } else {
            return imageURL?.url ?? ""
        }
    }

    var body: some View {
        if let isFavorited = isFavorited {
            ZStack {
                ImageView(withRequest: request, size: size, aspectRatio: aspectRatio, flipImage: flipImage, showPlaceholder: showPlaceholder)
                Image(systemName: isFavorited.wrappedValue ? "heart.fill" : "heart")
                    .font(.bold(size: 20))
                    .foregroundColor(isFavorited.wrappedValue ? Color.customAccent1 : Color.customRed)
                    .leftAligned()
                    .bottomAligned()
                    .padding(.leading, 20)
                    .padding(.bottom, 20)
            }
        } else {
            ImageView(withRequest: request, size: size, aspectRatio: aspectRatio, flipImage: flipImage, showPlaceholder: showPlaceholder)
        }
    }
}

struct ItemImageView_Previews: PreviewProvider {
    static var previews: some View {
        ItemImageView(withImageURL: nil, requestInfo: [], size: 80, aspectRatio: 1)
    }
}
