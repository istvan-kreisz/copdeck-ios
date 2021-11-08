//
//  SearchView.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import SwiftUI
import Combine

struct SearchView: View {
    @EnvironmentObject var store: DerivedGlobalStore

    @State private var searchText = ""

    @StateObject private var searchResultsLoader = Loader()
    @StateObject private var popularItemsLoader = Loader()
    @StateObject private var userSearchResultsLoader = Loader()

    @State private var selectedTabIndex = 0

    @State var navigationDestination: Navigation<NavigationDestination> = .init(destination: .empty, show: false)

    @State var searchState = SearchState()

    var alert = State<(String, String)?>(initialValue: nil)

    var selectedItem: Item? {
        guard case let .itemDetail(item) = navigationDestination.destination else { return nil }
        return item
    }

    var selectedUser: ProfileData? {
        guard case let .profile(profile) = navigationDestination.destination else { return nil }
        return profile
    }

    var allItems: [Item] {
        let selectedItem: [Item] = selectedItem.map { (item: Item) in [item] } ?? []
        let searchResults: [Item] = searchState.searchResults
        let popularItems: [Item] = searchState.popularItems
        let favoritedItems: [Item] = store.globalState.favoritedItems
        let recentlyViewed: [Item] = store.globalState.recentlyViewedItems
        return (selectedItem + searchResults + popularItems + favoritedItems + recentlyViewed).uniqued()
    }

    var allProfiles: [ProfileData] {
        let selectedProfile: [ProfileData] = selectedUser.map { (profile: ProfileData) in [profile] } ?? []
        let searchResults: [ProfileData] = searchState.userSearchResults.map { (user: User) in ProfileData(user: user, stacks: [], inventoryItems: []) }
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
            let showDetail = Binding<Bool>(get: { navigationDestination.show },
                                           set: { show in show ? navigationDestination.display() : navigationDestination.hide() })
            let selectedItemBinding = Binding<Item?>(get: { selectedItem },
                                                     set: { item in
                                                         if let item = item {
                                                             navigationDestination += .itemDetail(item)
                                                         } else {
                                                             navigationDestination.hide()
                                                         }
                                                     })
            let selectedUserBinding = Binding<ProfileData?>(get: { selectedUser },
                                                            set: { profile in
                                                                if let profile = profile {
                                                                    navigationDestination += .profile(profile)
                                                                } else {
                                                                    navigationDestination.hide()
                                                                }
                                                            })
            NavigationLink(destination: Destination(store: store,
                                                    popularItems: $searchState.popularItems,
                                                    favoritedItems: $store.globalState.favoritedItems,
                                                    navigationDestination: $navigationDestination)
                    .navigationbarHidden(),
                isActive: showDetail) { EmptyView() }

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
                                           isContentLocked: false,
                                           button: nil,
                                           size: (UIScreen.screenWidth - Styles.horizontalMargin * 2) / 2)
                    .frame(width: UIScreen.screenWidth - Styles.horizontalMargin * 2)
                    .withDefaultPadding(padding: .horizontal)

                if selectedTabIndex == 0 {
                    if searchState.searchResults.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HorizontaltemListView(items: $searchState.popularItems,
                                                  selectedItem: selectedItemBinding,
                                                  isLoading: $popularItemsLoader.isLoading,
                                                  title: "Trending now",
                                                  requestInfo: store.globalState.requestInfo,
                                                  style: .round) { navigationDestination += .popularItems }

                            HorizontaltemListView(items: $store.globalState.favoritedItems,
                                                  selectedItem: selectedItemBinding,
                                                  isLoading: .constant(false),
                                                  title: "Your favorites",
                                                  requestInfo: store.globalState.requestInfo,
                                                  style: .square(.customRed)) { navigationDestination += .favoritedItems }

                            HorizontaltemListView(items: $store.globalState.recentlyViewedItems,
                                                  selectedItem: selectedItemBinding,
                                                  isLoading: .constant(false),
                                                  title: "Recently viewed",
                                                  requestInfo: store.globalState.requestInfo,
                                                  sortedBy: .created,
                                                  style: .square(.clear))
                            Spacer()
                        }
                    } else {
                        VerticalItemListView(items: $searchState.searchResults,
                                             selectedItem: selectedItemBinding,
                                             isLoading: $searchResultsLoader.isLoading,
                                             title: nil,
                                             resultsLabelText: nil,
                                             bottomPadding: Styles.tabScreenBottomPadding,
                                             requestInfo: store.globalState.requestInfo)
                    }
                } else {
                    VerticalProfileListView(profiles: $searchState.userSearchResults.asProfiles,
                                            selectedProfile: selectedUserBinding,
                                            isLoading: $userSearchResultsLoader.isLoading,
                                            bottomPadding: Styles.tabScreenBottomPadding)
                }
            }
            .hideKeyboardOnScroll()
            .onChange(of: searchText) { search(searchTerm: $0) }
            .onAppear {
                if searchState.popularItems.isEmpty {
                    store.send(.main(action: .getPopularItems(completion: { result in
                        handleResult(result: result, loader: nil) { self.searchState.popularItems = $0 }
                    })))
                }
            }
            .withAlert(alert: alert.projectedValue)
        }
    }

    private func search(searchTerm: String) {
        if selectedTabIndex == 0 {
            let loader = searchResultsLoader.getLoader()
            store.send(.main(action: .getSearchResults(searchTerm: searchText, completion: { result in
                handleResult(result: result, loader: loader) { self.searchState.searchResults = $0 }
            })))
        } else {
            let loader = userSearchResultsLoader.getLoader()
            store.send(.main(action: .searchUsers(searchTerm: searchText, completion: { result in
                handleResult(result: result, loader: loader) { self.searchState.userSearchResults = $0 }
            })))
        }
    }
}

extension SearchView: LoadViewWithAlert {}

extension SearchView {
    enum NavigationDestination: Equatable {
        case popularItems, favoritedItems, itemDetail(Item), profile(ProfileData), empty
    }

    struct Destination: View {
        var store: DerivedGlobalStore
        @Binding var popularItems: [Item]
        @Binding var favoritedItems: [Item]
        @Binding var navigationDestination: Navigation<NavigationDestination>

        var body: some View {
            switch navigationDestination.destination {
            case .popularItems:
                PopularItemsListView(items: $popularItems,
                                     requestInfo: store.globalState.requestInfo,
                                     favoritedItemIds: store.globalState.favoritedItems.map(\.id))
            case .favoritedItems:
                PopularItemsListView(items: $favoritedItems,
                                     requestInfo: store.globalState.requestInfo,
                                     favoritedItemIds: store.globalState.favoritedItems.map(\.id))
            case let .itemDetail(item):
                ItemDetailView(item: item,
                               itemId: item.id,
                               favoritedItemIds: store.globalState.favoritedItems.map(\.id)) { navigationDestination.hide() }
                    .environmentObject(AppStore.default)
            case let .profile(profileData):
                ProfileView(profileData: profileData) { navigationDestination.hide() }
            case .empty:
                EmptyView()
            }
        }
    }
}

#warning("check if publishers terminate correctly in all cases")
