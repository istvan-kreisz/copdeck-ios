//
//  ImageView.swift
//  CopDeck
//
//  Created by István Kreisz on 2/14/21.
//

import SwiftUI
import NukeUI
import Nuke

struct ImageView: View {
    let request: ImageRequestConvertible
    let size: CGFloat
    let aspectRatio: CGFloat?
    let flipImage: Bool
    let showPlaceholder: Bool
    let resizingMode: ImageResizingMode

    init(withRequest request: ImageRequestConvertible,
         size: CGFloat,
         aspectRatio: CGFloat?,
         flipImage: Bool = false,
         showPlaceholder: Bool = true,
         resizingMode: ImageResizingMode = .aspectFit) {
        self.request = request
        self.size = size
        self.aspectRatio = aspectRatio
        self.flipImage = flipImage
        self.showPlaceholder = showPlaceholder
        self.resizingMode = resizingMode
    }

    var body: some View {
        LazyImage(source: request) { state in
            if let image = state.image {
                image.resizingMode(.aspectFit)
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
        .background(Color.customWhite)
        .frame(width: size, height: size)
        .if(flipImage) { $0.scaleEffect(CGSize(width: -1.0, height: 1.0)) }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(withRequest: "", size: 80, aspectRatio: 1)
    }
}
