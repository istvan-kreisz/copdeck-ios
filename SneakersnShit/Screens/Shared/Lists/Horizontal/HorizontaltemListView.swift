//
//  HorizontaltemListView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/10/21.
//

import SwiftUI
import Combine

struct HorizontaltemListView: View {
    private static let maxHorizontalItemCount = 6

    @Binding var items: [Item]?
    @Binding var selectedItem: Item?
    @Binding var showPopularItems: Bool
    @ObservedObject var loader: Loader

    let title: String?
    var requestInfo: [ScraperRequestInfo]

    var itemsToShow: [Item] {
        items?.first(n: Self.maxHorizontalItemCount) ?? []
    }

    var body: some View {
        if !itemsToShow.isEmpty {
            VStack(alignment: .leading, spacing: 15) {
                if let title = title {
                    Text(title)
                        .foregroundColor(.customText1)
                        .font(.bold(size: 22))
                        .leftAligned()
                        .withDefaultPadding(padding: .horizontal)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        Color.clear
                            .frame(width: 0, height: 0)
                            .padding(.leading, Styles.horizontalPadding - 24)
                        ForEach(itemsToShow) { item in
                            HorizontalListItem(title: item.name ?? "",
                                               imageURL: item.imageURL,
                                               flipImage: item.imageURL?.store.id == .klekt,
                                               requestInfo: requestInfo,
                                               index: itemsToShow.firstIndex(where: { $0.id == item.id }) ?? 0) { selectedItem = item }
                        }
                        if (items?.count ?? 0) > Self.maxHorizontalItemCount {
                            Button(action: {
                                showPopularItems = true
                            }, label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.customBlue)
                                        .frame(width: HorizontalListItem.size, height: HorizontalListItem.size)
                                        .cornerRadius(HorizontalListItem.size / 2)
                                        .withDefaultShadow()
                                    Text("See\nmore")
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.customWhite)
                                        .font(.semiBold(size: 13))
                                }
                            })
                        }
                        Color.clear
                            .frame(width: 0, height: 0)
                            .padding(.trailing, Styles.horizontalPadding - 24)
                    }
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 6)
        }
    }
}

struct HorizontaltemListView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontaltemListView(items: .constant([.sample, .sample]),
                              selectedItem: .constant(nil),
                              showPopularItems: .constant(false),
                              loader: Loader(),
                              title: "title",
                              requestInfo: [])
    }
}
