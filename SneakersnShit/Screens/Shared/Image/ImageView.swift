//
//  ImageView.swift
//  CopDeck
//
//  Created by István Kreisz on 2/14/21.
//

import SwiftUI
import NukeUI
import Nuke
import Combine

enum ImageViewSourceType {
    case url(ImageRequestConvertible?)
    case publisher(AnyPublisher<ImageRequestConvertible?, Never>)
}

struct ImageView: View {
    @State private var source: ImageRequestConvertible?
    let publisher: AnyPublisher<ImageRequestConvertible?, Never>
    let size: CGFloat
    let aspectRatio: CGFloat?
    let flipImage: Bool
    let showPlaceholder: Bool
    let background: Color
    let resizingMode: ImageResizingMode

    var didLoadImage: ((_ image: UIImage, _ url: String?) -> Void)?

    init(source: ImageViewSourceType,
         size: CGFloat,
         aspectRatio: CGFloat?,
         flipImage: Bool = false,
         showPlaceholder: Bool = true,
         resizingMode: ImageResizingMode = .aspectFit,
         background: Color = .customWhite,
         didLoadImage: ((UIImage, String?) -> Void)? = nil) {
        switch source {
        case let .url(url):
            self._source = State(initialValue: url)
            self.publisher = Empty<ImageRequestConvertible?, Never>(completeImmediately: true).eraseToAnyPublisher()
        case let .publisher(publisher):
            self._source = State(initialValue: nil)
            self.publisher = publisher
        }
        self.size = size
        self.aspectRatio = aspectRatio
        self.flipImage = flipImage
        self.showPlaceholder = showPlaceholder
        self.resizingMode = resizingMode
        self.background = background
        self.didLoadImage = didLoadImage
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.customAccent2)
                .frame(width: size, height: size)
            if let source = source, !DebugSettings.shared.blockImageDownload {
                LazyImage(source: source) { state in
                    if let image = state.image {
                        image.resizingMode(resizingMode).background(Color.customWhite)
                    } else if state.error != nil {
                        if DebugSettings.shared.isInDebugMode {
                            Color.customAccent2
                        } else {
                            if showPlaceholder {
                                Color.customWhite
                            } else {
                                Color.clear
                            }
                        }
                    } else {
                        if showPlaceholder {
                            Color.customAccent2
                        } else {
                            Color.clear
                        }
                    }
                }
                .onSuccess {
                    if let imageRequest = source as? ImageRequest {
                        didLoadImage?($0.image, imageRequest.url?.absoluteString)
                    }
                }
                .onFailure { response in
                    if let url  = (self.source as? ImageRequest)?.url?.absoluteString {
                        if !DefaultImageService.failedFetchURLs.contains(url) {
                            DefaultImageService.failedFetchURLs.append(url)
                        }
                    }
                }
                .background(background)
                .frame(width: size, height: size)
                .scaleEffect(CGSize(width: flipImage ? -1.0 : 1.0, height: 1.0))
            }
        }
        .cornerRadius(Styles.cornerRadius)
        .onReceive(publisher) { source in
            self.source = source
        }
    }
}
