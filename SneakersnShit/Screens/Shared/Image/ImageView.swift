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
    let resizingMode: ImageResizingMode

    var didLoadImage: ((UIImage) -> Void)?

    init(source: ImageViewSourceType,
         size: CGFloat,
         aspectRatio: CGFloat?,
         flipImage: Bool = false,
         showPlaceholder: Bool = true,
         resizingMode: ImageResizingMode = .aspectFit,
         didLoadImage: ((UIImage) -> Void)? = nil) {
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
        self.didLoadImage = didLoadImage
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.customAccent2)
                .frame(width: size, height: size)
            if let source = source {
                LazyImage(source: source) { state in
                    if let image = state.image {
                        image.resizingMode(resizingMode)
                    } else if state.error != nil {
                        if DebugSettings.shared.isInDebugMode {
                            Color.customRed
                        } else {
                            if showPlaceholder {
                                Color(.secondarySystemBackground)
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
                    if source is ImageRequest {
                        didLoadImage?($0.image)
                    }
                }
                .background(Color.customWhite)
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
