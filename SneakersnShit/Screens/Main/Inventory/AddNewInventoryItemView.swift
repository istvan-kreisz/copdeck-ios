//
//  AddNewInventoryItemView.swift
//  CopDeck
//
//  Created by István Kreisz on 11/8/21.
//

import Foundation
import SwiftUI

struct AddNewInventoryItemView: View {
    @EnvironmentObject var store: DerivedGlobalStore

    @State private var searchText = ""
    @StateObject private var searchResultsLoader = Loader()

    @State var navigationDestination: Navigation<NavigationDestination> = .init(destination: .empty, show: false)

    @State var searchState = SearchState()

    var alert = State<(String, String)?>(initialValue: nil)

    var selectedItem: Item? {
        guard case let .itemDetail(item) = navigationDestination.destination else { return nil }
        return item
    }

    var body: some View {
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

        NavigationView {
            VStack(alignment: .leading, spacing: 19) {
                NavigationLink(destination: Destination(store: store, navigationDestination: $navigationDestination),
                    isActive: showDetail) { EmptyView() }

                Text("Add New Item")
                    .font(.bold(size: 28))
                    .foregroundColor(.customText1)
                    .padding(.bottom, 18)
                    .padding(.top, 8)
                    .centeredHorizontally()

                TextFieldRounded(title: nil,
                                 placeHolder: "Search sneakers, apparel, collectibles",
                                 style: .white,
                                 text: $searchText)
                    .withDefaultPadding(padding: .horizontal)

                if searchState.searchResults.isEmpty {
                    // add manually
                    HStack(alignment: .center, spacing: 16) {
                        Text("OR")
                            .font(.bold(size: 16))
                            .foregroundColor(.customText1)
                        AccessoryButton(title: "Add manually",
                                        color: .customBlue,
                                        textColor: .customBlue,
                                        width: nil,
                                        imageName: "plus",
                                        tapped: { navigationDestination += .itemDetail(nil) })
                        Spacer()
                    }
                    .withDefaultPadding(padding: .horizontal)
                    Spacer()
                } else {
                    VerticalItemListView(items: $searchState.searchResults,
                                         selectedItem: selectedItemBinding,
                                         isLoading: $searchResultsLoader.isLoading,
                                         title: nil,
                                         resultsLabelText: nil,
                                         bottomPadding: 0)
                }
            }
            .background(Color.customBackground)
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
            .navigationbarHidden()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.light)
    }

    private func search(searchTerm: String) {
        let loader = searchResultsLoader.getLoader()
        store.send(.main(action: .getSearchResults(searchTerm: searchText, completion: { result in
            handleResult(result: result, loader: loader) { self.searchState.searchResults = $0 }
        })))
    }
}

extension AddNewInventoryItemView: LoadViewWithAlert {}

extension AddNewInventoryItemView {
    enum NavigationDestination: Equatable {
        case itemDetail(Item?), empty
    }

    struct Destination: View {
        var store: DerivedGlobalStore
        @Binding var navigationDestination: Navigation<NavigationDestination>

        var body: some View {
            switch navigationDestination.destination {
            case let .itemDetail(item):
                if let item = item {
                    ItemDetailView(item: item,
                                   itemId: item.id,
                                   favoritedItemIds: store.globalState.favoritedItems.map(\.id)) { navigationDestination.hide() }
                        .environmentObject(AppStore.default)
                } else {
                    Text("asuasodsd")
                }
            case .empty:
                EmptyView()
            }
        }
    }
}
