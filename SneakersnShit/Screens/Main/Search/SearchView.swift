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

    @StateObject private var searchResultsLoader = Loader()
    @StateObject private var popularItemsLoader = Loader()
    @StateObject private var userSearchResultsLoader = Loader()

    @State private var selectedTabIndex = 0

    @State private var navigationDestination: NavigationDestination?

    var selectedItem: Item? {
        guard case let .itemDetail(item) = navigationDestination else { return nil }
        return item
    }

    var selectedUser: ProfileData? {
        guard case let .profile(profile) = navigationDestination else { return nil }
        return profile
    }

    var allItems: [Item] {
        let selectedItem: [Item] = selectedItem.map { (item: Item) in [item] } ?? []
        let searchResults: [Item] = store.state.searchResults
        let popularItems: [Item] = store.state.popularItems
        let favoritedItems: [Item] = store.state.favoritedItems
        let recentlyViewed: [Item] = store.state.recentlyViewed
        return (selectedItem + searchResults + popularItems + favoritedItems + recentlyViewed).uniqued()
    }

    var allProfiles: [ProfileData] {
        let selectedProfile: [ProfileData] = selectedUser.map { (profile: ProfileData) in [profile] } ?? []
        let searchResults: [ProfileData] = store.state.userSearchResults.map { (user: User) in ProfileData(user: user, stacks: [], inventoryItems: []) }
        var uniqued: [ProfileData] = []
        (selectedProfile + searchResults).forEach { profileData in
            if !uniqued.contains(where: { $0.user.id == profileData.user.id }) {
                uniqued.append(profileData)
            }
        }
        return uniqued
    }

    var body: some View {
        Group {
            let showDetail = Binding<Bool>(get: { navigationDestination != nil },
                                           set: { show in navigationDestination = show ? navigationDestination : nil })
            let selectedItemBinding = Binding<Item?>(get: { selectedItem },
                                                     set: { item in navigationDestination = item.map { .itemDetail($0) } ?? nil })
            let selectedUserBinding = Binding<ProfileData?>(get: { selectedUser },
                                                            set: { profile in navigationDestination = profile.map { .profile($0) } ?? nil })
            NavigationLink(destination: Destination(navigationDestination: $navigationDestination), isActive: showDetail) { EmptyView() }

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
                                           size: (UIScreen.screenWidth - Styles.horizontalMargin * 2) / 2)
                    .frame(width: UIScreen.screenWidth - Styles.horizontalMargin * 2)
                    .withDefaultPadding(padding: .horizontal)

                if selectedTabIndex == 0 {
                    if store.state.searchResults.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HorizontaltemListView(items: $store.state.popularItems,
                                                  selectedItem: selectedItemBinding,
                                                  isLoading: $popularItemsLoader.isLoading,
                                                  title: "Trending now",
                                                  requestInfo: store.state.requestInfo,
                                                  style: .round) { navigationDestination = .popularItems }

                            HorizontaltemListView(items: $store.state.favoritedItems,
                                                  selectedItem: selectedItemBinding,
                                                  isLoading: .constant(false),
                                                  title: "Your favorites",
                                                  requestInfo: store.state.requestInfo,
                                                  style: .square(.customRed)) { navigationDestination = .favoritedItems }

                            HorizontaltemListView(items: $store.state.recentlyViewed,
                                                  selectedItem: selectedItemBinding,
                                                  isLoading: .constant(false),
                                                  title: "Recently viewed",
                                                  requestInfo: store.state.requestInfo,
                                                  sortedBy: .created,
                                                  style: .square(.clear))
                            Spacer()
                        }
                    } else {
                        VerticalItemListView(items: $store.state.searchResults,
                                             selectedItem: selectedItemBinding,
                                             isLoading: $searchResultsLoader.isLoading,
                                             title: nil,
                                             resultsLabelText: nil,
                                             bottomPadding: Styles.tabScreenBottomPadding,
                                             requestInfo: store.state.requestInfo)
                    }
                } else {
                    VerticalProfileListView(profiles: $store.state.userSearchResults.asProfiles,
                                            selectedProfile: selectedUserBinding,
                                            isLoading: $userSearchResultsLoader.isLoading,
                                            bottomPadding: Styles.tabScreenBottomPadding)
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

extension SearchView {
    enum NavigationDestination {
        case popularItems, favoritedItems, itemDetail(Item), profile(ProfileData)
    }

    struct Destination: View {
        @EnvironmentObject var store: AppStore
        @Binding var navigationDestination: NavigationDestination?

        var body: some View {
            switch navigationDestination {
            case .popularItems:
                PopularItemsListView(items: $store.state.popularItems,
                                     requestInfo: store.state.requestInfo,
                                     favoritedItemIds: store.state.favoritedItems.map(\.id))
            case .favoritedItems:
                PopularItemsListView(items: $store.state.favoritedItems,
                                     requestInfo: store.state.requestInfo,
                                     favoritedItemIds: store.state.favoritedItems.map(\.id))
            case let .itemDetail(item):
                ItemDetailView(item: item,
                               itemId: item.id,
                               favoritedItemIds: store.state.favoritedItems.map(\.id)) { navigationDestination = nil }
            case let .profile(profileData):
                ProfileView(profileData: profileData) { navigationDestination = nil }
            case .none:
                EmptyView()
            }
        }
    }
}
