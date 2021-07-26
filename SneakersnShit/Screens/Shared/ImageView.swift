//
//  ImageView.swift
//  CopDeck
//
//  Created by István Kreisz on 2/14/21.
//

import SwiftUI
import NukeUI

struct ImageView: View {
    let url: String
    let size: CGFloat
    let aspectRatio: CGFloat?
    let showPlaceholder: Bool

    init(withURL url: String, size: CGFloat, aspectRatio: CGFloat?, showPlaceholder: Bool = true) {
        self.url = url
        self.size = size
        self.aspectRatio = aspectRatio
        self.showPlaceholder = showPlaceholder
    }

    var body: some View {
        #if DEBUG
            if url.isEmpty {
                Image("logo")
                    .resizable()
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .frame(width: size, height: size)
            } else {
                LazyImage(source: url) { state in
                    if let image = state.image {
                        image.resizingMode(.aspectFit)
                    } else if showPlaceholder {
                        Color(.secondarySystemBackground)
                    } else {
                        Color.clear
                    }
                }
                .frame(width: size, height: size)
            }
        #else
            LazyImage(source: url) { state in
                if let image = state.image {
                    image.resizingMode(.aspectFit)
                } else if showPlaceholder {
                    Color(.secondarySystemBackground)
                } else {
                    Color.clear
                }
            }
            .frame(width: size, height: size)
        #endif
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(withURL: "", size: 80, aspectRatio: 1)
    }
}
