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
    @State private var selectedUser: User?

    @StateObject private var searchResultsLoader = Loader()
    @StateObject private var popularItemsLoader = Loader()
    @StateObject private var userSearchResultsLoader = Loader()

    @State private var showPopularItems = false

    @State private var selectedTabIndex = 0

    var allItems: [Item] {
        let selectedItem: [Item] = selectedItem.map { (item: Item) in [item] } ?? []
        let searchResults: [Item] = store.state.searchResults
        let popularItems: [Item] = store.state.popularItems
        let favoritedItems: [Item] = store.state.favoritedItems
        let recentlyViewed: [Item] = store.state.recentlyViewed
        return (selectedItem + searchResults + popularItems + favoritedItems + recentlyViewed).uniqued()
    }

    var body: some View {
        Group {
            let selectedItemId = Binding<String?>(get: { selectedItem?.id },
                                                  set: { selectedItem = $0 != nil ? selectedItem : nil })
            NavigationLink(destination: EmptyView()) { EmptyView() }
            ForEach(allItems) { (item: Item) in
                NavigationLink(destination: ItemDetailView(item: item,
                                                           itemId: item.id,
                                                           favoritedItemIds: store.state.favoritedItems.map(\.id)) { selectedItem = nil },
                               tag: item.id,
                               selection: selectedItemId) { EmptyView() }
            }

            NavigationLink(destination:
                PopularItemsListView(showView: $showPopularItems,
                                     items: $store.state.popularItems,
                                     requestInfo: store.state.requestInfo,
                                     favoritedItemIds: store.state.favoritedItems.map(\.id)),
                isActive: $showPopularItems) { EmptyView() }

            VStack(alignment: .leading, spacing: 19) {
                Text("Search")
                    .foregroundColor(.customText1)
                    .font(.bold(size: 35))
                    .leftAligned()
                    .padding(.leading, 6)
                    .withDefaultPadding(padding: .horizontal)

                TextFieldRounded(title: nil,
                                 placeHolder: selectedTabIndex == 0 ? "Search sneakers" : "Search people",
                                 style: .white,
                                 text: $searchText)
                    .withDefaultPadding(padding: .horizontal)

                ScrollableSegmentedControl(selectedIndex: $selectedTabIndex,
                                           titles: .constant(["Sneakers", "People"]),
                                           button: nil,
                                           size: (UIScreen.screenWidth - Styles.horizontalPadding * 2) / 2)
                    .frame(width: UIScreen.screenWidth - Styles.horizontalPadding * 2)
                    .withDefaultPadding(padding: .horizontal)

                if selectedTabIndex == 0 {
                    if store.state.searchResults.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HorizontaltemListView(items: $store.state.popularItems,
                                                  selectedItem: $selectedItem,
                                                  isLoading: $popularItemsLoader.isLoading,
                                                  title: "Trending now",
                                                  requestInfo: store.state.requestInfo) { showPopularItems = true }

                            HorizontaltemListView(items: $store.state.favoritedItems,
                                                  selectedItem: $selectedItem,
                                                  isLoading: .constant(false),
                                                  title: "Your favorites",
                                                  requestInfo: store.state.requestInfo)

                            HorizontaltemListView(items: $store.state.recentlyViewed,
                                                  selectedItem: $selectedItem,
                                                  isLoading: .constant(false),
                                                  title: "Recently viewed",
                                                  requestInfo: store.state.requestInfo,
                                                  sortedBy: .created)
                            Spacer()
                        }
                    } else {
                        VerticalItemListView(items: $store.state.searchResults,
                                             selectedItem: $selectedItem,
                                             isLoading: $searchResultsLoader.isLoading,
                                             title: nil,
                                             resultsLabelText: nil,
                                             bottomPadding: 130,
                                             requestInfo: store.state.requestInfo)
                    }
                } else {
                    VerticalUserListView(users: $store.state.userSearchResults,
                                         selectedUser: $selectedUser,
                                         isLoading: $userSearchResultsLoader.isLoading,
                                         bottomPadding: 130)
                }
            }
            .onChange(of: searchText) { searchText in
                if selectedTabIndex == 0 {
                    store.send(.main(action: .getSearchResults(searchTerm: searchText)), completed: searchResultsLoader.getLoader())
                } else {
                    store.send(.main(action: .searchUsers(searchTerm: searchText)), completed: userSearchResultsLoader.getLoader())
                }
            }
            .onAppear {
                if store.state.popularItems.isEmpty {
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
