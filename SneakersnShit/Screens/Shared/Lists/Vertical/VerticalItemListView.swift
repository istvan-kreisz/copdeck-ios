//
//  VerticalItemListView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/10/21.
//

import SwiftUI
import Combine

struct VerticalItemListView: View {
    @Binding var items: [Item]?
    @Binding var selectedItem: Item?
    @ObservedObject var loader: Loader

    let title: String?
    let bottomPadding: CGFloat
    var requestInfo: [ScraperRequestInfo]

//    var itemsPlusSelectedItem: [Item] {
//        let allItems = items ?? []
//        if let selectedItem = selectedItem {
//            if allItems.contains(where: { $0.id == selectedItem.id }) {
//                return allItems
//            } else {
//                return allItems + [selectedItem]
//            }
//        } else {
//            return allItems
//        }
//    }

    var body: some View {
//        let selectedItemId = Binding<String?>(get: { selectedItem?.id },
//                                              set: { selectedItem = $0 == nil ? nil : selectedItem })
//        ForEach(itemsPlusSelectedItem) { item in
//            NavigationLink(destination: ItemDetailView(item: item,
//                                                       itemId: item.id,
//                                                       showAddToInventoryButton: true),
//                           tag: item.id,
//                           selection: selectedItemId) { EmptyView() }
//        }

        VStack(alignment: .leading, spacing: 19) {
            if let title = title {
                Text(title)
                    .foregroundColor(.customText1)
                    .font(.bold(size: 35))
                    .leftAligned()
                    .padding(.leading, 6)
                    .withDefaultPadding(padding: .horizontal)
            }

            ScrollView(.vertical, showsIndicators: false) {
                if loader.isLoading {
                    CustomSpinner(text: "Loading...", animate: true)
                        .padding(.horizontal, 22)
                        .padding(.top, 5)
                }
                if let resultCount = items?.count {
                    Text("\(resultCount) Results:")
                        .font(.bold(size: 12))
                        .leftAligned()
                        .padding(.horizontal, 28)
                }

                ForEach(items ?? []) { item in
                    VerticalListItem<EmptyView>(title: item.name ?? "",
                                        imageURL: item.imageURL,
                                        flipImage: item.imageURL?.store.id == .klekt,
                                        requestInfo: requestInfo,
                                        isEditing: .constant(false),
                                        isSelected: false) { selectedItem = item }
                }
                .withDefaultPadding(padding: .horizontal)
                .padding(.vertical, 6)

                Color.clear.padding(.bottom, bottomPadding)
            }
        }
    }
}

struct VerticalItemListView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            VerticalItemListView(items: .constant([.sample, .sample]),
                                 selectedItem: .constant(.sample),
                                 loader: Loader(),
                                 title: "title",
                                 bottomPadding: 130,
                                 requestInfo: [])
        }
    }
}
