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

    init(withURL url: String, size: CGFloat, aspectRatio: CGFloat?) {
        self.url = url
        self.size = size
        self.aspectRatio = aspectRatio
    }

    var body: some View {
        #if DEBUG
            if url.isEmpty {
                Image("dude")
                    .resizable()
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .frame(width: size, height: size)
            } else {
                LazyImage(source: url, resizingMode: .aspectFit)
                    .frame(width: size, height: size)
            }
        #else
            LazyImage(source: url, resizingMode: .aspectFit)
                .frame(width: size, height: size)
        #endif
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(withURL: "", size: 80, aspectRatio: 1)
    }
}
