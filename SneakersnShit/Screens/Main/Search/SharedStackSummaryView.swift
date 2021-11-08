//
//  SharedStackSummaryView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/1/21.
//

import SwiftUI

struct SharedStackSummaryView: View {
    private static let maxCount = 4
    private static let profileImageSize: CGFloat = 38

    @Binding var selectedInventoryItem: InventoryItem?
    @Binding var selectedStack: Stack?

    @State var stack: Stack

    let stackOwnerId: String
    let userId: String
    let userCountry: String?
    
    var countryIcon: String {
        if let countryName = userCountry {
            return Country(rawValue: countryName)?.icon ?? ""
        } else {
            return ""
        }
    }

    let inventoryItems: [InventoryItem]

    let profileInfo: (username: String, imageURL: URL?)?

    var didTapProfile: (() -> Void)? = nil

    var notShownItemCount: Int {
        inventoryItems.count - Self.maxCount
    }

    var publishedDate: String {
        stack.publishedDate?.asDateFormat1 ?? ""
    }

    var isLikedByUser: Bool {
        stack.likes?.contains(userId) == true
    }

    var body: some View {
        VStack(spacing: 0) {
            if let profileInfo = profileInfo {
                HStack {
                    ImageView(source: .url(profileInfo.imageURL),
                              size: Self.profileImageSize,
                              aspectRatio: 1.0,
                              flipImage: false,
                              showPlaceholder: true,
                              resizingMode: .aspectFill)
                        .frame(width: Self.profileImageSize, height: Self.profileImageSize)
                        .cornerRadius(Self.profileImageSize / 2)
                    VStack(alignment: .leading) {
                        Text("\(profileInfo.username) \(countryIcon)")
                            .font(.bold(size: 14))
                            .foregroundColor(.customText1)

                        Text(publishedDate)
                            .font(.regular(size: 12))
                            .foregroundColor(.customText2)
                    }
                    Spacer()
                }
                .padding(.bottom, 12)
                .onTapGesture {
                    didTapProfile?()
                }
            }
            if let caption = stack.caption, !caption.isEmpty {
                Text(caption)
                    .font(.regular(size: 14))
                    .foregroundColor(.customText1)
                    .leftAligned()
                    .padding(.bottom, 8)
            }
            VStack {
                ForEach(inventoryItems.first(n: Self.maxCount)) { (inventoryItem: InventoryItem) in
                    StackSummaryListItem(inventoryItem: inventoryItem, selectedInventoryItem: $selectedInventoryItem)
                }
                AccessoryButton(title: "See details \(notShownItemCount > 0 ? "(+\(notShownItemCount) more items)" : "")",
                                color: .customAccent1,
                                textColor: .customText1,
                                fontSize: 11,
                                width: nil,
                                imageName: "chevron.right",
                                buttonPosition: .right,
                                tapped: { selectedStack = stack })
                    .leftAligned()
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: Styles.cornerRadius).fill(Color.customWhite).withDefaultShadow())

            HStack(spacing: 4) {
                Button {
                    toggleLike()
                } label: {
                    if isLikedByUser {
                        Image(systemName: "heart.fill")
                            .renderingMode(.template)
                            .font(.semiBold(size: 17))
                            .foregroundColor(.customRed)
                    } else {
                        Image(systemName: "heart")
                            .font(.semiBold(size: 17))
                            .foregroundColor(Color.customText1)
                    }
                }
                Text((stack.likes?.count).map { $0 > 0 ? "\($0)" : "" } ?? "")
                    .font(.regular(size: 14))
                    .foregroundColor(.customText1)
                Spacer()
            }
            .padding(.leading, 10)
            .padding(.top, 10)
        }
        .padding(.top, 22)
    }

    private func toggleLike() {
        var likes = stack.likes ?? []
        if isLikedByUser {
            likes.removeAll(where: { $0 == userId })
        } else {
            likes.append(userId)
        }
        AppStore.default.environment.feedbackGenerator.selectionChanged()
        stack.likes = likes
        AppStore.default.send(.main(action: .toggleLike(stack: stack, stackOwnerId: stackOwnerId)))
    }
}
