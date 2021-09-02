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

    let profileData: ProfileData
    let inventoryItem: InventoryItem
    let requestInfo: [ScraperRequestInfo]

    let shouldDismiss: () -> Void

    var body: some View {
        Group {
            VerticalListView(bottomPadding: 30, spacing: 2, addHorizontalPadding: false) {
                NavigationBar(title: profileData.user.name.map { "\($0)'s sneaker" } ?? "sneaker details",
                              isBackButtonVisible: true,
                              style: .dark,
                              shouldDismiss: shouldDismiss)
                    .withDefaultPadding(padding: .horizontal)

                OwnerCardView(user: profileData.user)

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
