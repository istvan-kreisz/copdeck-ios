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

    @Binding var selectedInventoryItemId: String?
    @Binding var selectedStackId: String?

    let stack: Stack

    let inventoryItems: [InventoryItem]
    let requestInfo: [ScraperRequestInfo]

    let profileInfo: (username: String, imageURL: URL?)?

    var didTapProfile: (() -> Void)? = nil

    var notShownItemCount: Int {
        inventoryItems.count - Self.maxCount
    }

//    https://stackoverflow.com/questions/35700281/date-format-in-swift
    var publishedDate: String {
        guard let published = stack.publishedDate else { return "" }
        let publishedDate = Date(timeIntervalSince1970: published / 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: publishedDate)
    }

    var body: some View {
        VStack(spacing: 0) {
            if let profileInfo = profileInfo {
                HStack {
                    ImageView(withRequest: profileInfo.imageURL,
                              size: Self.profileImageSize,
                              aspectRatio: 1.0,
                              flipImage: false,
                              showPlaceholder: true,
                              resizingMode: .aspectFill)
                        .frame(width: Self.profileImageSize, height: Self.profileImageSize)
                        .cornerRadius(Self.profileImageSize / 2)
                    VStack(alignment: .leading) {
                        Text(profileInfo.username)
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
                    StackSummaryListItem(inventoryItem: inventoryItem, selectedInventoryItemId: $selectedInventoryItemId, requestInfo: requestInfo)
                }
                AccessoryButton(title: "See details \(notShownItemCount > 0 ? "(+\(notShownItemCount) more items)" : "")",
                                color: .customAccent1,
                                textColor: .customText1,
                                fontSize: 11,
                                width: nil,
                                imageName: "chevron.right",
                                buttonPosition: .right,
                                tapped: { selectedStackId = stack.id })
                    .leftAligned()
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: Styles.cornerRadius).fill(Color.customWhite).withDefaultShadow())
        }
        .padding(.top, 22)
    }
}
