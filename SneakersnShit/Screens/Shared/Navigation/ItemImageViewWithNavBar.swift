//
//  ItemImageViewWithNavBar.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct ItemImageViewWithNavBar: View {
    @Binding var showView: Bool
    let imageURL: ImageURL?
    let requestInfo: [ScraperRequestInfo]

    var body: some View {
        ZStack {
            Color.customWhite.edgesIgnoringSafeArea(.all)
            if let imageURL = self.imageURL {
                ItemImageView(withImageURL: imageURL,
                              requestInfo: requestInfo,
                              size: UIScreen.main.bounds.width - 80,
                              aspectRatio: nil,
                              flipImage: imageURL.store.id == .klekt,
                              showPlaceholder: false)
            } else {
                Color.clear
                    .frame(width: UIScreen.main.bounds.width - 80, height: UIScreen.main.bounds.width - 80)
            }
            NavigationBar(showView: $showView, title: nil, isBackButtonVisible: true, style: .dark)
                .withDefaultPadding(padding: .horizontal)
                .topAligned()
        }
    }
}

struct ItemImageViewWithNavBar_Previews: PreviewProvider {
    static var previews: some View {
        return ItemImageViewWithNavBar(showView: .constant(false), imageURL: nil, requestInfo: [])
    }
}
