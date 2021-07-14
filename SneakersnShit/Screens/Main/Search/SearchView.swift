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
    @Binding var hasPushedView: Bool

    @StateObject private var loader = Loader()

    var body: some View {
        let selectedId = Binding<String?>(get: { selectedItemId },
                                          set: { id in
                                              selectedItemId = id
                                              hasPushedView = id != nil
                                          })
        ZStack {
            Color.customBackground.edgesIgnoringSafeArea(.all)
            ForEach(store.state.searchResults ?? []) { item in
                NavigationLink(destination: ItemDetailView(item: item),
                               tag: item.id,
                               selection: self.$selectedItemId) { EmptyView() }
            }
            VStack(alignment: .leading, spacing: 19) {
                Text("Search")
                    .font(.bold(size: 35))
                    .leftAligned()
                    .padding(.leading, 6)
                    .padding(.horizontal, 28)

                CustomTextField(title: nil, placeHolder: "Search sneakers", text: $searchText)
                    .padding(.horizontal, 22)

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
                        HStack(alignment: .center, spacing: 10) {
                            ImageView(withURL: item.bestStoreInfo?.imageURL ?? "", size: 58, aspectRatio: nil)
                                .cornerRadius(8)
                            Text((item.bestStoreInfo ?? item.storeInfo.first)?.name ?? "")
                                .font(.bold(size: 14))
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .frame(height: 85)
                        .background(Color.white)
                        .cornerRadius(12)
                        .withDefaultShadow()
                        .onTapGesture {
                            selectedId.wrappedValue = item.id
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 6)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .frame(maxWidth: UIScreen.main.bounds.width)
        }
        .navigationBarHidden(selectedItemId == nil)
        .onChange(of: searchText) { searchText in
            store.send(.getSearchResults(searchTerm: searchText), completed: loader.getLoader())
        }
    }

    func addToInventory(item: Item) {
//        store.send(.addToInventory(inventoryItem: .init(from: item)))
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        let store = AppStore(initialState: .mockAppState,
                             reducer: appReducer,
                             environment: World(isMockInstance: true))
        return Group {
            SearchView(hasPushedView: .constant(false))
                .environmentObject(store
                    .derived(deriveState: \.mainState,
                             deriveAction: AppAction.main,
                             derivedEnvironment: store.environment.main))
        }
    }
}
