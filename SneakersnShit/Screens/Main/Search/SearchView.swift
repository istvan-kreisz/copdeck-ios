//
//  SearchView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/30/21.
//

import SwiftUI
import Combine

struct SearchView: View {
    @EnvironmentObject var store: MainStore

    let colors: [Color] = [.red, .yellow, .green, .purple, .orange]

    @State private var searchText = ""
    @State private var selectedItemId: String?

    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    ForEach(store.state.searchResults ?? []) { item in
                        NavigationLink(destination: ItemDetailView(item: item),
                                       tag: item.id,
                                       selection: self.$selectedItemId) { EmptyView() }
                    }
                    TextField("Search", text: $searchText)
                        .padding(.vertical)

                    ForEach(store.state.searchResults ?? []) { item in
                        HStack {
                            ImageView(withURL: item.bestStoreInfo?.imageURL ?? "", size: 80)
                                .cornerRadius(8)
                            VStack {
                                HStack {
                                    Text((item.bestStoreInfo ?? item.storeInfo.first)?.name ?? "")
                                        .font(.semiBold(size: 13))
                                    Spacer()
                                }
                                HStack(spacing: 10) {
                                    ForEach(item.storeInfo) { storeInfo in
                                        Text(storeInfo.store.name.rawValue)
                                            .font(.regular(size: 12))
                                    }
                                    Spacer()
                                }
                                .frame(maxWidth: 300)
                            }
                        }.onTapGesture {
                            selectedItemId = item.id
                        }
                    }
                }
                .withDefaultPadding()
            }
            .frame(maxWidth: UIScreen.main.bounds.width)
        }
        .onChange(of: searchText) { searchText in
            store.send(.getSearchResults(searchTerm: searchText))
        }
        .onAppear {
            store.send(.getSearchResults(searchTerm: ""))
        }
    }

//    func addToInventory(item: Item) {
//        store.send(.addToInventory(inventoryItem: .init(from: item)))
//    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        let store = AppStore(initialState: .mockAppState,
                             reducer: appReducer,
                             environment: World(isMockInstance: true))
        return Group {
            SearchView()
                .environmentObject(store
                    .derived(deriveState: \.mainState,
                             deriveAction: AppAction.main,
                             derivedEnvironment: store.environment.main))
        }
    }
}
