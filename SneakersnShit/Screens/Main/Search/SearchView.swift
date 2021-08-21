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

    var allItems: [Item] {
        ((selectedItem.map { [$0] } ?? []) + (store.state.searchResults ?? []) + (store.state.popularItems ?? [])).uniqued()
    }

    var body: some View {
        Group {
            let showSelectedItem = Binding<Bool>(get: { selectedItem?.id != nil },
                                                 set: { selectedItem = $0 ? selectedItem : nil })
            let selectedItemId = Binding<String?>(get: { selectedItem?.id },
                                                  set: { selectedItem = $0 != nil ? selectedItem : nil })
            NavigationLink(destination: EmptyView()) { EmptyView() }
            ForEach(allItems) { item in
                NavigationLink(destination: ItemDetailView(item: item, showView: showSelectedItem, itemId: item.id),
                               tag: item.id,
                               selection: selectedItemId) { EmptyView() }
            }

            NavigationLink(destination:
                PopularItemsListView(showView: $showPopularItems,
                                     items: $store.state.popularItems,
                                     requestInfo: store.state.requestInfo),
                isActive: $showPopularItems) { EmptyView() }

            VStack(alignment: .leading, spacing: 19) {
                Text("Search")
                    .foregroundColor(.customText1)
                    .font(.bold(size: 35))
                    .leftAligned()
                    .padding(.leading, 6)
                    .withDefaultPadding(padding: .horizontal)

                if let item = store.state.searchResults?.first {
                    VerticalListItemWithoutAccessoryView(title: item.name ?? "",
                                                         imageURL: item.imageURL,
                                                         flipImage: item.imageURL?.store.id == .klekt,
                                                         requestInfo: store.state.requestInfo,
                                                         isEditing: .constant(false),
                                                         isSelected: false) { selectedItem = item }
                }

                TextFieldRounded(title: nil,
                                 placeHolder: "Search sneakers",
                                 style: .white,
                                 text: $searchText)
                    .withDefaultPadding(padding: .horizontal)

                HorizontaltemListView(items: $store.state.popularItems,
                                      selectedItem: $selectedItem,
                                      isLoading: $popularItemsLoader.isLoading,
                                      showPopularItems: $showPopularItems,
                                      title: "Trending now",
                                      requestInfo: store.state.requestInfo)

                VerticalItemListView(items: $store.state.searchResults,
                                     selectedItem: $selectedItem,
                                     isLoading: $searchResultsLoader.isLoading,
                                     title: nil,
                                     resultsLabelText: "Search results:",
                                     bottomPadding: 130,
                                     requestInfo: store.state.requestInfo)
            }
            .onChange(of: searchText) { searchText in
                store.send(.main(action: .getSearchResults(searchTerm: searchText)), completed: searchResultsLoader.getLoader())
            }
            .onAppear {
                if store.state.popularItems?.isEmpty != false {
                    store.send(.main(action: .getPopularItems), completed: popularItemsLoader.getLoader())
                }
            }
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
