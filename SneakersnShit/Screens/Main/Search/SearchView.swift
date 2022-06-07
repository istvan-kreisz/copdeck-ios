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

    @StateObject private var popularItemsLoader = Loader()
    @StateObject private var userSearchResultsLoader = Loader()

    @State private var selectedTabIndex = 0
    @State private var isFirstload = true

    @State var navigationDestination: Navigation<NavigationDestination> = .init(destination: .empty, show: false)
    
    @Binding var lastItemId: String?
    
    var searchText: State<String> = State(initialValue: "")
    var searchModel: StateObject<SearchModel> = StateObject(wrappedValue: SearchModel())
    var searchResultsLoader: StateObject<Loader> = StateObject(wrappedValue: Loader())

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
                                                    popularItems: searchModel.projectedValue.state.popularItems,
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
                                 text: searchText.projectedValue,
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
                    if searchText.wrappedValue.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HorizontaltemListView(items: searchModel.projectedValue.state.popularItems,
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
                                                  maxHorizontalItemCount: 30,
                                                  sortedBy: .created,
                                                  style: .square(.clear))
                            Spacer()
                        }
                    } else {
                        VerticalItemListView(items: searchModel.projectedValue.state.searchResults.searchResults,
                                             selectedItem: selectedItemBinding,
                                             isLoading: searchResultsLoader.projectedValue.isLoading,
                                             title: nil,
                                             resultsLabelText: nil,
                                             bottomPadding: Styles.tabScreenBottomPadding)
                    }
                } else {
                    VerticalProfileListView(profiles: searchModel.projectedValue.state.userSearchResults.asProfiles,
                                            selectedProfile: selectedUserBinding,
                                            isLoading: $userSearchResultsLoader.isLoading,
                                            bottomPadding: Styles.tabScreenBottomPadding)
                }
            }
            .hideKeyboardOnScroll()
            .onChange(of: searchText.wrappedValue) {
                if lastItemId == nil {
                    search(searchTerm: $0, isExactSearchById: false)
                } else {
                    search(searchTerm: $0, isExactSearchById: true)
                    self.lastItemId = nil
                }
            }
            .onChange(of: lastItemId) { lastItemId in
                if let itemId = lastItemId {
                    self.searchText.wrappedValue = itemId
                }
            }
            .onAppear {
                if searchModel.wrappedValue.state.popularItems.isEmpty {
                    store.send(.main(action: .getPopularItems(completion: { result in
                        handleResult(result: result, loader: nil) { self.searchModel.wrappedValue.state.popularItems = $0 }
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

    private func search(searchTerm: String, isExactSearchById: Bool) {
        if selectedTabIndex == 0 {
            searchItems(searchTerm: searchTerm, isExactSearchById: isExactSearchById) {
                // deep linking from notifications
                if isExactSearchById {
                    if let selectedItem = searchModel.wrappedValue.state.searchResults.searchResults.first(where: { $0.id.lowercased() == searchTerm.lowercased() }) {
                        navigationDestination += .itemDetail(selectedItem)
                    }
                }
            }
        } else {
            if searchTerm.isEmpty {
                self.searchModel.wrappedValue.state.userSearchResults = []
            } else {
                let loader = userSearchResultsLoader.getLoader()
                store.send(.main(action: .searchUsers(searchTerm: searchText.wrappedValue, completion: { result in
                    if searchTerm == self.searchText.wrappedValue {
                        handleResult(result: result, loader: loader) { self.searchModel.wrappedValue.state.userSearchResults = $0 }
                    }
                })), debounceDelayMs: 900)
            }
        }
    }
}

extension SearchView: ItemSearchView {}

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
                ItemsListView(items: $popularItems, favoritedItemIds: store.globalState.favoritedItems.map(\.id), title: "Trending now")
            case .favoritedItems:
                ItemsListView(items: $favoritedItems, favoritedItemIds: store.globalState.favoritedItems.map(\.id), title: "Favorites")
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
