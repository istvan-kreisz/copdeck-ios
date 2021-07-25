//
//  InventoryView.swift
//  CopDeck
//
//  Created by István Kreisz on 3/30/21.
//

import SwiftUI
import Combine

struct InventoryView: View {
    @EnvironmentObject var authStore: AppStore
    @State private var selectedInventoryItemId: String?

    var body: some View {EmptyView()}

//    var body: some View {
//        let selectedId = Binding<String?>(get: { selectedInventoryItemId },
//                                          set: { id in
//                                            selectedInventoryItemId = id
//                                              hasPushedView = id != nil
//                                          })
//        ZStack {
//            Color.customBackground.edgesIgnoringSafeArea(.all)
//            ForEach(store.state.searchResults ?? []) { item in
//                NavigationLink(destination: ItemDetailView(item: item),
//                               tag: item.id,
//                               selection: $selectedItemId) { EmptyView() }
//            }
//            VStack(alignment: .leading, spacing: 19) {
//                Text("Search")
//                    .font(.bold(size: 35))
//                    .leftAligned()
//                    .padding(.leading, 6)
//                    .padding(.horizontal, 28)
//
//                TextFieldRounded(title: nil,
//                                 placeHolder: "Search sneakers",
//                                 style: .white,
//                                 text: $searchText)
//                    .padding(.horizontal, 22)
//
//                ScrollView(.vertical, showsIndicators: false) {
//                    if loader.isLoading {
//                        CustomSpinner(text: "Loading...", animate: true)
//                            .padding(.horizontal, 22)
//                            .padding(.top, 5)
//                    }
//                    if let resultCount = store.state.searchResults?.count {
//                        Text("\(resultCount) Results:")
//                            .font(.bold(size: 12))
//                            .leftAligned()
//                            .padding(.horizontal, 28)
//                    }
//
//                    ForEach(store.state.searchResults ?? []) { item in
//                        HStack(alignment: .center, spacing: 10) {
//                            ImageView(withURL: item.bestStoreInfo?.imageURL ?? "", size: 58, aspectRatio: nil)
//                                .cornerRadius(8)
//                            Text((item.bestStoreInfo ?? item.storeInfo.first)?.name ?? "")
//                                .font(.bold(size: 14))
//                            Spacer()
//                        }
//                        .padding(.horizontal, 8)
//                        .frame(height: 85)
//                        .background(Color.white)
//                        .cornerRadius(12)
//                        .withDefaultShadow()
//                        .onTapGesture {
//                            selectedId.wrappedValue = item.id
//                        }
//                    }
//                    .padding(.horizontal, 22)
//                    .padding(.vertical, 6)
//                }
//            }
//            .edgesIgnoringSafeArea(.bottom)
//            .frame(maxWidth: UIScreen.main.bounds.width)
//        }
//        .navigationbarHidden()
//        .onChange(of: searchText) { searchText in
//            store.send(.main(action: .getSearchResults(searchTerm: searchText)), completed: loader.getLoader())
//        }
//    }

//    func deleteFromInventory(inventoryItem: InventoryItem) {
//        store.send(.removeFromInventory(inventoryItem: inventoryItem))
//    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            InventoryView()
                .environmentObject(AppStore.default)
        }
    }
}
