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

    @StateObject private var loader = Loader()

    private static let maxPopularItemCount = 6

    var popularItems: [Item] {
        store.state.popularItems?.first(n: Self.maxPopularItemCount) ?? []
    }

    var searchResultsPlusSelectedItem: [Item] {
        let searchResults = store.state.searchResults ?? []
        if let selectedItem = selectedItem {
            if searchResults.contains(where: { $0.id == selectedItem.id }) {
                return searchResults
            } else {
                return searchResults + [selectedItem]
            }
        } else {
            return searchResults
        }
    }

    var body: some View {
        let selectedItemId = Binding<String?>(get: { selectedItem?.id },
                                              set: { selectedItem = $0 == nil ? nil : selectedItem })
        ForEach(searchResultsPlusSelectedItem) { item in
            NavigationLink(destination: ItemDetailView(item: item, itemId: item.id, showAddToInventoryButton: true),
                           tag: item.id,
                           selection: selectedItemId) { EmptyView() }
        }
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

            if !popularItems.isEmpty {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Trending now")
                        .foregroundColor(.customText1)
                        .font(.bold(size: 22))
                        .leftAligned()
                        .withDefaultPadding(padding: .horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            Color.clear
                                .frame(width: 0, height: 0)
                                .padding(.leading, Styles.horizontalPadding - 24)
                            ForEach(popularItems) { item in
                                HorizontalListItem(title: item.name ?? "",
                                                   imageURL: item.imageURL,
                                                   flipImage: item.imageURL?.store.id == .klekt,
                                                   requestInfo: store.state.requestInfo,
                                                   index: popularItems.firstIndex(where: { $0.id == item.id }) ?? 0) { selectedItem = item }
                            }
                            if store.state.popularItems?.count ?? 0 > Self.maxPopularItemCount {
                                Button(action: {
                                    print("------------------")
                                    print("sdsdsds")
                                    print("------------------")

                                }, label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.customBlue)
                                            .frame(width: HorizontalListItem.size, height: HorizontalListItem.size)
                                            .cornerRadius(HorizontalListItem.size / 2)
                                            .withDefaultShadow()
                                        Text("See\nmore")
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.customWhite)
                                            .font(.semiBold(size: 13))
                                    }
                                })
                            }
                            Color.clear
                                .frame(width: 0, height: 0)
                                .padding(.trailing, Styles.horizontalPadding - 24)
                        }
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 6)
            }

            ScrollView(.vertical, showsIndicators: false) {
                if loader.isLoading {
                    CustomSpinner(text: "Loading...", animate: true)
                        .padding(.horizontal, 22)
                        .padding(.top, 5)
                }
                if let resultCount = store.state.searchResults?.count {
                    Text("\(resultCount) Results:")
                        .font(.bold(size: 12))
                        .leftAligned()
                        .padding(.horizontal, 28)
                }

                ForEach(store.state.searchResults ?? []) { item in
                    ListItem<EmptyView>(title: item.name ?? "",
                                        imageURL: item.imageURL,
                                        flipImage: item.imageURL?.store.id == .klekt,
                                        requestInfo: store.state.requestInfo,
                                        isEditing: .constant(false),
                                        isSelected: false) { selectedItem = item }
                }
                .withDefaultPadding(padding: .horizontal)
                .padding(.vertical, 6)

                Color.clear.padding(.bottom, 130)
            }
        }
        .onChange(of: searchText) { searchText in
            store.send(.main(action: .getSearchResults(searchTerm: searchText)), completed: loader.getLoader())
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
