//
//  HorizontaltemListView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/10/21.
//

import SwiftUI
import Combine

struct HorizontaltemListView: View {
    enum Style {
        case round, square(Color)
    }

    private static let maxHorizontalItemCount = 20

    @Binding var items: [Item]
    @Binding var selectedItem: Item?
    @Binding var isLoading: Bool

    let title: String?
    var requestInfo: [ScraperRequestInfo]
    var sortedBy: DateType? = nil
    let style: Style

    var moreTapped: (() -> Void)? = nil

    var itemsToShow: [Item] {
        if let sortedBy = sortedBy {
            return items.first(n: Self.maxHorizontalItemCount).sortedByDate(dateType: sortedBy, sortOrder: .descending)
        } else {
            return items.first(n: Self.maxHorizontalItemCount)
        }
    }

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 2) {
                if let title = title {
                    Text(title)
                        .foregroundColor(.customText1)
                        .font(.bold(size: 22))
                        .leftAligned()
                        .withDefaultPadding(padding: .horizontal)
                }
//                if isLoading {
//                    CustomSpinner(text: "Loading...", animate: true)
//                        .padding(.horizontal, 22)
//                        .padding(.top, 5)
//                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        Color.clear
                            .frame(width: 0, height: 0)
                            .padding(.leading, Styles.horizontalMargin - 24)
                        ForEach(itemsToShow) { (item: Item) in
                            switch style {
                            case .round:
                                HorizontalListItemRound(itemId: item.id,
                                    title: item.name ?? "",
                                                        source: imageSource(for: item),
                                                        flipImage: item.imageURL?.store?.id == .klekt,
                                                        requestInfo: requestInfo,
                                                        index: itemsToShow.firstIndex(where: { $0.id == item.id }) ?? 0,
                                                        onTapped: { selectedItem = item })
                            case let .square(color):
                                HorizontalListItemSquare(itemId: item.id,
                                    title: item.name ?? "",
                                                         source: imageSource(for: item),
                                                         flipImage: item.imageURL?.store?.id == .klekt,
                                                         requestInfo: requestInfo,
                                                         index: itemsToShow.firstIndex(where: { $0.id == item.id }) ?? 0,
                                                         color: color, onTapped: { selectedItem = item })
                            }
                        }
                        if let moreTapped = moreTapped, items.count > Self.maxHorizontalItemCount {
                            Button(action: moreTapped) {
                                ZStack {
                                    Circle()
                                        .fill(Color.customBlue)
                                        .frame(width: HorizontalListItemRound.size, height: HorizontalListItemRound.size)
                                        .cornerRadius(HorizontalListItemRound.size / 2)
                                        .withDefaultShadow()
                                    Text("See\nmore")
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.customWhite)
                                        .font(.semiBold(size: 13))
                                }
                            }
                        }
                        Color.clear
                            .frame(width: 0, height: 0)
                            .padding(.trailing, Styles.horizontalMargin - 24)
                    }
                    .frame(height: HorizontalListItemRound.size + 20)
                }
            }
        }
    }
}
