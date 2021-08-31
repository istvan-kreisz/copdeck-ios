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

    init(withImageURL imageURL: ImageURL?,
         requestInfo: [ScraperRequestInfo],
         size: CGFloat,
         aspectRatio: CGFloat?,
         flipImage: Bool = false,
         showPlaceholder: Bool = true) {
        self.imageURL = imageURL
        self.requestInfo = requestInfo
        self.size = size
        self.aspectRatio = aspectRatio
        self.flipImage = flipImage
        self.showPlaceholder = showPlaceholder
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
        ImageView(withRequest: request, size: size, aspectRatio: aspectRatio, flipImage: flipImage, showPlaceholder: showPlaceholder)
    }
}

struct ItemImageView_Previews: PreviewProvider {
    static var previews: some View {
        ItemImageView(withImageURL: nil, requestInfo: [], size: 80, aspectRatio: 1)
    }
}
