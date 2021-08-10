//
//  SearchView.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import SwiftUI
import Combine

struct SearchView: View {
    @EnvironmentObject var store: AppStore

    @State private var searchText = ""
    @State private var selectedItem: Item?

    @StateObject private var searchResultsLoader = Loader()
    @StateObject private var popularItemsLoader = Loader()

    @State private var showPopularItems = false

    var body: some View {
        let showSelectedItem = Binding<Bool>(get: { selectedItem?.id != nil },
                                             set: {
                                                selectedItem = $0 ? selectedItem : nil
                                             })
        if let selectedItem = selectedItem {
            NavigationLink(destination: ItemDetailView(item: selectedItem,
                                                       showView: showSelectedItem,
                                                       itemId: selectedItem.id,
                                                       showAddToInventoryButton: true),
                           isActive: showSelectedItem) { EmptyView() }
        }
        NavigationLink(destination: FeedView(),
                       isActive: $showPopularItems) { EmptyView() }
        VStack(alignment: .leading, spacing: 19) {
            Text("Search")
                .foregroundColor(.customText1)
                .font(.bold(size: 35))
                .leftAligned()
                .padding(.leading, 6)
                .withDefaultPadding(padding: .horizontal)

            TextFieldRounded(title: nil,
                             placeHolder: "Search sneakers",
                             style: .white,
                             text: $searchText)
                .withDefaultPadding(padding: .horizontal)

            HorizontaltemListView(items: $store.state.popularItems,
                                  selectedItem: $selectedItem,
                                  showPopularItems: $showPopularItems,
                                  loader: popularItemsLoader,
                                  title: "Trending now",
                                  requestInfo: store.state.requestInfo)

            VerticalItemListView(items: $store.state.searchResults,
                                 selectedItem: $selectedItem,
                                 loader: searchResultsLoader,
                                 title: nil,
                                 resultsLabelText: "Search results:",
                                 bottomPadding: 130,
                                 requestInfo: store.state.requestInfo)
        }
        .onChange(of: searchText) { searchText in
            store.send(.main(action: .getSearchResults(searchTerm: searchText)), completed: searchResultsLoader.getLoader())
        }
        .onAppear {
            store.send(.main(action: .getPopularItems))
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            SearchView()
                .environmentObject(AppStore.default)
        }
    }
}
