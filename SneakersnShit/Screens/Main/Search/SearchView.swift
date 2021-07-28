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
    @State private var selectedItemId: String?

    @StateObject private var loader = Loader()

    var body: some View {
        ForEach(store.state.searchResults ?? []) { item in
            NavigationLink(destination: ItemDetailView(item: item, itemId: item.id, showAddToInventoryButton: true),
                           tag: item.id,
                           selection: $selectedItemId) { EmptyView() }
        }
        VStack(alignment: .leading, spacing: 19) {
            Text("Search")
                .foregroundColor(.customText1)
                .font(.bold(size: 35))
                .leftAligned()
                .padding(.leading, 6)
                .padding(.horizontal, 28)

            TextFieldRounded(title: nil,
                             placeHolder: "Search sneakers",
                             style: .white,
                             text: $searchText)
                .withDefaultPadding(padding: .horizontal)

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
                                        isSelected: false) {
                        selectedItemId = item.id
                    }
                }
                .withDefaultPadding(padding: .horizontal)
                .padding(.vertical, 6)

                Color.clear.padding(.bottom, 130)
            }
        }
        .onChange(of: searchText) { searchText in
            store.send(.main(action: .getSearchResults(searchTerm: searchText)), completed: loader.getLoader())
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
