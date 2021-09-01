//
//  ItemImageViewWithNavBar.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct ItemImageViewWithNavBar: View {
    let imageURL: ImageURL?
    let requestInfo: [ScraperRequestInfo]
    var shouldDismiss: () -> Void
    var isFavorited: Binding<Bool>?

    let size = UIScreen.main.bounds.width - 80

    var body: some View {
        ZStack {
            Color.customWhite.edgesIgnoringSafeArea(.all)
            if let imageURL = self.imageURL {
                ItemImageView(withImageURL: imageURL,
                              requestInfo: requestInfo,
                              size: size,
                              aspectRatio: nil,
                              flipImage: imageURL.store?.id == .klekt,
                              showPlaceholder: false)
            } else {
                Color.clear
                    .frame(width: UIScreen.main.bounds.width - 80, height: UIScreen.main.bounds.width - 80)
            }
            if let isFavorited = isFavorited {
                Button {
                    isFavorited.wrappedValue.toggle()
                } label: {
                    Image(systemName: isFavorited.wrappedValue ? "heart.fill" : "heart")
                        .font(.regular(size: size / 10))
                        .foregroundColor(isFavorited.wrappedValue ? Color.customRed : Color.customAccent1)
                }
                .rightAligned()
                .bottomAligned()
                .padding(.trailing, 20)
            }
            NavigationBar(title: nil, isBackButtonVisible: true, style: .dark, shouldDismiss: shouldDismiss)
                .withDefaultPadding(padding: .horizontal)
                .topAligned()
        }
    }
}

struct ItemImageViewWithNavBar_Previews: PreviewProvider {
    static var previews: some View {
        return ItemImageViewWithNavBar(imageURL: nil, requestInfo: []) {}
    }
}
