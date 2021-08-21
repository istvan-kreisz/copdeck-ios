//
//  PopularItemsListView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/11/21.
//

import SwiftUI
import Combine

struct PopularItemsListView: View {
    @Binding var showView: Bool
    @Binding var items: [Item]?
    let requestInfo: [ScraperRequestInfo]

    @State private var selectedItem: Item?

    var body: some View {
        Group {
            let showSelectedItem = Binding<Bool>(get: { selectedItem?.id != nil },
                                                 set: { selectedItem = $0 ? selectedItem : nil })
            let selectedItemId = Binding<String?>(get: { selectedItem?.id }, set: { selectedItem = $0 == nil ? nil : selectedItem })

            NavigationLink(destination: EmptyView()) { EmptyView() }
            ForEach(items ?? []) { item in
                NavigationLink(destination: ItemDetailView(item: item, showView: showSelectedItem, itemId: item.id),
                               tag: item.id,
                               selection: selectedItemId) { EmptyView() }
            }
            VStack(alignment: .center, spacing: 8) {
                NavigationBar(showView: $showView, title: "Trending now", isBackButtonVisible: true, style: .dark)
                    .withDefaultPadding(padding: .horizontal)

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
