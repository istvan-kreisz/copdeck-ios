//
//  PopularItemsListView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/11/21.
//

import SwiftUI
import Combine

struct PopularItemsListView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var items: [Item]

    let requestInfo: [ScraperRequestInfo]
    let favoritedItemIds: [String]

    @State private var selectedItem: Item?

    var body: some View {
        Group {
            NavigationLink(destination: EmptyView()) { EmptyView() }
            ForEach(items) { (item: Item) in
                NavigationLink(destination: ItemDetailView(item: item,
                                                           itemId: item.id,
                                                           favoritedItemIds: favoritedItemIds) { selectedItem = nil },
                               tag: item.id,
                               selection: convertToId(_selectedItem)) { EmptyView() }
            }
            VStack(alignment: .center, spacing: 8) {
                NavigationBar(title: "Trending now", isBackButtonVisible: true, style: .dark) { presentationMode.wrappedValue.dismiss() }
                    .withDefaultPadding(padding: [.horizontal, .top])

                VerticalItemListView(items: $items,
                                     selectedItem: $selectedItem,
                                     isLoading: .constant(false),
                                     title: nil,
                                     resultsLabelText: nil,
                                     bottomPadding: 30,
                                     requestInfo: requestInfo)
            }
            .edgesIgnoringSafeArea(.bottom)
            .frame(maxWidth: UIScreen.main.bounds.width)
            .withDefaultPadding(padding: .top)
            .withBackgroundColor()
            .navigationbarHidden()
        }
    }
}
