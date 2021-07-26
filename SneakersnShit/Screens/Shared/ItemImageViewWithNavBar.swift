//
//  ItemImageViewWithNavBar.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct ItemImageViewWithNavBar: View {
    let imageURL: ImageURL?

    var body: some View {
        ZStack {
            ImageView(withURL: imageURL?.url ?? "",
                      size: UIScreen.main.bounds.width - 80,
                      aspectRatio: nil,
                      flipImage: imageURL?.store.id == .klekt,
                      showPlaceholder: false)
            NavigationBar(title: nil, isBackButtonVisible: true, style: .dark)
                .withDefaultPadding(padding: .horizontal)
                .topAligned()
        }
    }
}

struct ItemImageViewWithNavBar_Previews: PreviewProvider {
    static var previews: some View {
        return ItemImageViewWithNavBar(imageURL: nil)
    }
}