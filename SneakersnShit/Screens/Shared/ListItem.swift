//
//  ListItem.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct ListItem: View {
    var title: String
    var imageURL: String?
    var accessoryView: AnyView? = nil
    var onTapped: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ImageView(withURL: imageURL ?? "", size: 62, aspectRatio: nil)
                .cornerRadius(8)
            VStack {
                Text(title)
                    .font(.bold(size: 14))
                    .leftAligned()
                accessoryView
                if accessoryView == nil {
                    Spacer()
                }
            }
        }
        .padding(12)
        .frame(height: 86)
        .background(Color.white)
        .cornerRadius(12)
        .withDefaultShadow()
        .onTapGesture(perform: onTapped)
    }
}

struct ListItem_Previews: PreviewProvider {
    static var previews: some View {
        return ListItem(title: "yooo",
                        imageURL: "https://images.stockx.com/images/Adidas-Yeezy-Boost-350-V2-Core-Black-Red-2017-Product.jpg?fit=fill&bg=FFFFFF&w=700&h=500&auto=format,compress&trim=color&q=90&dpr=2&updated_at=1606320792",
                        onTapped: {})
    }
}
