//
//  SearchView.swift
//  CopDeck
//
//  Created by István Kreisz on 1/30/21.
//

import SwiftUI
import Combine
import Firebase

struct SearchView: View {
    @EnvironmentObject var store: DerivedGlobalStore

    @State private var searchText = ""

    @StateObject private var searchResultsLoader = Loader()
    @StateObject private var popularItemsLoader = Loader()
    @StateObject private var userSearchResultsLoader = Loader()

    @State private var selectedTabIndex = 0
    @State private var isFirstload = true

    @State var navigationDestination: Navigation<NavigationDestination> = .init(destination: .empty, show: false)

    @StateObject var searchModel = SearchModel()

    var alert = State<(String, String)?>(initialValue: nil)

    var selectedItem: ItemSearchResult? {
        guard case let .itemDetail(item) = navigationDestination.destination else { return nil }
        return item
    }

    var selectedUser: ProfileData? {
        guard case let .profile(profile) = navigationDestination.destination else { return nil }
        return profile
    }

    var body: some View {
        Group {
            let showDetail = Binding<Bool>(get: { navigationDestination.show },
                                           set: { show in show ? navigationDestination.display() : navigationDestination.hide() })
            let selectedItemBinding = Binding<ItemSearchResult?>(get: { selectedItem },
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
                                                    popularItems: $searchModel.state.popularItems,
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
                                 placeHolder: selectedTabIndex == 0 ? "Search sneakers, apparel, collectibles" : "Search people",
                                 style: .white,
                                 text: $searchText,
                                 addClearButton: true)
                    .withDefaultPadding(padding: .horizontal)

                ScrollableSegmentedControl(selectedIndex: $selectedTabIndex,
                                           titles: .constant(["Sneakers", "People"]),
                                           isContentLocked: false,
                                           button: nil,
                                           size: (UIScreen.screenWidth - Styles.horizontalMargin * 2) / 2)
                    .frame(width: UIScreen.screenWidth - Styles.horizontalMargin * 2)
                    .withDefaultPadding(padding: .horizontal)

                if selectedTabIndex == 0 {
                    if searchText.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HorizontaltemListView(items: $searchModel.state.popularItems,
                                                  selectedItem: selectedItemBinding,
                                                  isLoading: $popularItemsLoader.isLoading,
                                                  title: "Trending now",
                                                  style: .round) { navigationDestination += .popularItems }

                            HorizontaltemListView(items: $store.globalState.favoritedItems,
                                                  selectedItem: selectedItemBinding,
                                                  isLoading: .constant(false),
                                                  title: "Your favorites",
                                                  style: .square(.customRed)) { navigationDestination += .favoritedItems }

                            HorizontaltemListView(items: $store.globalState.recentlyViewedItems,
                                                  selectedItem: selectedItemBinding,
                                                  isLoading: .constant(false),
                                                  title: "Recently viewed",
                                                  sortedBy: .created,
                                                  style: .square(.clear))
                            Spacer()
                        }
                    } else {
                        VerticalItemListView(items: $searchModel.state.searchResults.searchResults,
                                             selectedItem: selectedItemBinding,
                                             isLoading: $searchResultsLoader.isLoading,
                                             title: nil,
                                             resultsLabelText: nil,
                                             bottomPadding: Styles.tabScreenBottomPadding)
                    }
                } else {
                    VerticalProfileListView(profiles: $searchModel.state.userSearchResults.asProfiles,
                                            selectedProfile: selectedUserBinding,
                                            isLoading: $userSearchResultsLoader.isLoading,
                                            bottomPadding: Styles.tabScreenBottomPadding)
                }
            }
            .hideKeyboardOnScroll()
            .onChange(of: searchText) { search(searchTerm: $0) }
            .onAppear {
                if searchModel.state.popularItems.isEmpty {
                    store.send(.main(action: .getPopularItems(completion: { result in
                        handleResult(result: result, loader: nil) { self.searchModel.state.popularItems = $0 }
                    })))
                }
                if isFirstload {
                    Analytics.logEvent("visited_search", parameters: ["userId": AppStore.default.state.globalState.user?.id ?? ""])
                    isFirstload = false
                }
            }
            .withAlert(alert: alert.projectedValue)
        }
    }
    
    private func getSearchResults(searchTerm: String, sendFetchRequest: Bool, loader: @escaping (Result<Void, AppError>) -> Void) {
        store.send(.main(action: .getSearchResults(searchTerm: searchTerm, sendFetchRequest: sendFetchRequest, completion: { result in
            if searchTerm == self.searchText {
                handleResult(result: result, loader: nil) { items in
                    if self.searchModel.state.searchResults.searchTerm == searchTerm {
                        let currentIds = self.searchModel.state.searchResults.searchResults.map(\.id)
                        let newItems = items.filter { !currentIds.contains($0.id) }
                        self.searchModel.state.searchResults.searchResults += newItems
                        loader(.success(()))
                    } else {
                        self.searchModel.state.searchResults = .init(searchTerm: searchTerm, searchResults: items)
                    }
                }
            }
        })), debounceDelayMs: sendFetchRequest ? 1000 : 300)
    }

    private func search(searchTerm: String) {
        if selectedTabIndex == 0 {
            if searchTerm.isEmpty {
                self.searchModel.state.searchResults = .init(searchTerm: "")
            } else {
                let loader = searchResultsLoader.getLoader()
                getSearchResults(searchTerm: searchTerm, sendFetchRequest: true, loader: loader)
                getSearchResults(searchTerm: searchTerm, sendFetchRequest: false, loader: loader)
            }
        } else {
            if searchTerm.isEmpty {
                self.searchModel.state.userSearchResults = []
            } else {
                let loader = userSearchResultsLoader.getLoader()
                store.send(.main(action: .searchUsers(searchTerm: searchText, completion: { result in
                    if searchTerm == self.searchText {
                        handleResult(result: result, loader: loader) { self.searchModel.state.userSearchResults = $0 }
                    }
                })), debounceDelayMs: 900)
            }
        }
    }
}

extension SearchView: LoadViewWithAlert {}

extension SearchView {
    enum NavigationDestination: Equatable {
        case popularItems, favoritedItems, itemDetail(ItemSearchResult), profile(ProfileData), empty
    }

    struct Destination: View {
        var store: DerivedGlobalStore
        @Binding var popularItems: [ItemSearchResult]
        @Binding var favoritedItems: [ItemSearchResult]
        @Binding var navigationDestination: Navigation<NavigationDestination>

        var body: some View {
            switch navigationDestination.destination {
            case .popularItems:
                PopularItemsListView(items: $popularItems, favoritedItemIds: store.globalState.favoritedItems.map(\.id))
            case .favoritedItems:
                PopularItemsListView(items: $favoritedItems, favoritedItemIds: store.globalState.favoritedItems.map(\.id))
            case let .itemDetail(item):
                ItemDetailView(item: item,
                               itemId: item.id,
                               styleId: item.styleId ?? item.id,
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
