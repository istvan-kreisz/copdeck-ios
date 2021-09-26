//
//  SharedInventoryItemView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/2/21.
//

import SwiftUI
import Combine

struct SharedInventoryItemView: View {
    @EnvironmentObject var store: DerivedGlobalStore
    private static let profileImageSize: CGFloat = 38

    let user: User
    let inventoryItem: InventoryItem
    let requestInfo: [ScraperRequestInfo]

    let shouldDismiss: () -> Void

    @State var photoURLs: [URL] = []

    var photoURLsChunked: [(Int, [URL])] {
        Array(photoURLs.chunked(into: 3).enumerated())
    }

    var imageSize: CGFloat {
        (UIScreen.screenWidth - (Styles.horizontalPadding * 4.0) - (Styles.horizontalMargin * 2.0)) / 3
    }

    var username: String {
        if let name = user.name, !name.isEmpty {
            return name
        } else {
            return "Owner"
        }
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

                VStack(alignment: .leading, spacing: 9) {
                    Text("Stock photo:".uppercased())
                        .font(.bold(size: 12))
                        .foregroundColor(.customText2)
                        .leftAligned()

                    HStack(spacing: Styles.verticalPadding) {
                        ImageView(source: imageSource(for: inventoryItem),
                                  size: imageSize,
                                  aspectRatio: 1.0,
                                  flipImage: false,
                                  showPlaceholder: true)
                            .frame(width: imageSize, height: imageSize)
                            .cornerRadius(4)

                        Spacer()
                    }
                }
                .asCard()
                .withDefaultPadding(padding: .horizontal)
                .padding(.vertical, 6)

                VStack(alignment: .leading, spacing: 9) {
                    Text("\(username)'s photos:".uppercased())
                        .font(.bold(size: 12))
                        .foregroundColor(.customText2)
                        .leftAligned()

                    ForEach(photoURLsChunked, id: \.0) { (index: Int, urls: [URL]) in
                        HStack(spacing: Styles.verticalPadding) {
                            ForEach(urls, id: \.absoluteString) { (url: URL) in
                                ImageView(source: .url(url),
                                          size: imageSize,
                                          aspectRatio: 1.0,
                                          flipImage: false,
                                          showPlaceholder: true,
                                          background: Color.customAccent1.opacity(0.07))
                                    .frame(width: imageSize, height: imageSize)
                                    .cornerRadius(4)
                            }
                            if urls.count < 3 {
                                Spacer()
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
                .asCard()
                .withDefaultPadding(padding: .horizontal)
                .padding(.vertical, 6)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .edgesIgnoringSafeArea(.bottom)
        .frame(maxWidth: UIScreen.main.bounds.width)
        .withDefaultPadding(padding: .top)
        .withBackgroundColor()
        .onAppear {
            loadPhotos()
        }
        .navigationbarHidden()
    }

    private func loadPhotos() {
        store.send(.main(action: .getInventoryItemImages(userId: user.id, inventoryItem: inventoryItem, completion: { urls in
            photoURLs = urls
        })))
    }
}
