//
//  SharedInventoryItemView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/2/21.
//

import SwiftUI
import Combine

struct SharedInventoryItemView: View {
    private static let profileImageSize: CGFloat = 38

    let user: User
    let inventoryItem: InventoryItem
    let requestInfo: [ScraperRequestInfo]

    let shouldDismiss: () -> Void

    var imageSize: CGFloat {
        (UIScreen.screenWidth - (Styles.horizontalPadding * 4.0) - (Styles.horizontalMargin * 2.0)) / 3
    }

    var body: some View {
        Group {
            VerticalListView(bottomPadding: 30, spacing: 2, addHorizontalPadding: false) {
                NavigationBar(title: user.name.map { "\($0)'s sneaker" } ?? "sneaker details",
                              isBackButtonVisible: true,
                              style: .dark,
                              shouldDismiss: shouldDismiss)
                    .withDefaultPadding(padding: .horizontal)

                OwnerCardView(user: user)

                VStack(alignment: .leading, spacing: 8) {
                    Text(inventoryItem.name)
                        .font(.bold(size: 30))
                        .foregroundColor(.customText1)
                        .padding(.bottom, 8)
                    HStack(spacing: 10) {
                        VStack(spacing: 2) {
                            Text(inventoryItem.itemId ?? "")
                                .font(.bold(size: 20))
                                .foregroundColor(.customText1)
                            Text("Style")
                                .font(.regular(size: 15))
                                .foregroundColor(.customText2)
                        }
                        Spacer()
                        VStack(spacing: 2) {
                            Text(inventoryItem.size)
                                .font(.bold(size: 20))
                                .foregroundColor(.customText1)
                            Text("Size")
                                .font(.regular(size: 15))
                                .foregroundColor(.customText2)
                        }
                        Spacer()
                        VStack(spacing: 2) {
                            Text(inventoryItem.condition.rawValue)
                                .font(.bold(size: 20))
                                .foregroundColor(.customText1)
                            Text("Condition")
                                .font(.regular(size: 15))
                                .foregroundColor(.customText2)
                        }
                    }
                }
                .asCard()
                .withDefaultPadding(padding: .horizontal)

                GeometryReader { geometryProxy in
                    VStack(alignment: .leading, spacing: 9) {
                        Text("Stock photo:".uppercased())
                            .font(.bold(size: 12))
                            .foregroundColor(.customText2)
                            .leftAligned()

                        HStack(spacing: Styles.verticalPadding) {
                            if let url = inventoryItem.imageURL?.URL {
                                ImageView(withRequest: url,
                                          size: imageSize,
                                          aspectRatio: 1.0,
                                          flipImage: false,
                                          showPlaceholder: true)
                                    .frame(width: imageSize, height: imageSize)
                                    .cornerRadius(4)
                            }
                            Spacer()
                        }
                    }
                    .asCard()
                    .withDefaultPadding(padding: .horizontal)
                }
                .padding(.vertical, 6)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .edgesIgnoringSafeArea(.bottom)
        .frame(maxWidth: UIScreen.main.bounds.width)
        .withDefaultPadding(padding: .top)
        .withBackgroundColor()
        .navigationbarHidden()
    }
}
