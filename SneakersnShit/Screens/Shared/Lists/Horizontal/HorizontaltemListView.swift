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
    @Binding var isLoading: Bool
    @Binding var showPopularItems: Bool

    @State var showTitle = true

    let title: String?
    var requestInfo: [ScraperRequestInfo]

    var itemsToShow: [Item] {
        items?.first(n: Self.maxHorizontalItemCount) ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if let title = title {
                if items?.isEmpty == false || showTitle {
                    Text(title)
                        .foregroundColor(.customText1)
                        .font(.bold(size: 22))
                        .leftAligned()
                        .withDefaultPadding(padding: .horizontal)
                }
            }
            if isLoading {
                CustomSpinner(text: "Loading...", animate: true)
                    .padding(.horizontal, 22)
                    .padding(.top, 5)
            }

            if !itemsToShow.isEmpty {
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
                    .frame(height: HorizontalListItem.size)
                }
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 6)
        .onChange(of: isLoading) { isLoading in
            #warning("refactor")
            if !isLoading {
                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                    if !self.isLoading, self.itemsToShow.isEmpty {
                        showTitle = false
                    }
                }
            } else {
                showTitle = true
            }
        }
    }
}

struct HorizontaltemListView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontaltemListView(items: .constant([.sample, .sample]),
                              selectedItem: .constant(nil),
                              isLoading: .constant(true),
                              showPopularItems: .constant(false),
                              title: "title",
                              requestInfo: [])
    }
}
