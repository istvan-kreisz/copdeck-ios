//
//  InventoryView.swift
//  CopDeck
//
//  Created by István Kreisz on 3/30/21.
//

import SwiftUI
import Combine

struct InventoryView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedInventoryItemId: String?

    @State private var searchText = ""

    var body: some View {
        ZStack {
            Color.customBackground.edgesIgnoringSafeArea(.all)
            ForEach(store.state.inventoryItems) { inventoryItem in
                NavigationLink(destination: InventoryItemDetailView(inventoryItem: inventoryItem),
                               tag: inventoryItem.id,
                               selection: $selectedInventoryItemId) { EmptyView() }
            }
            VStack(alignment: .leading, spacing: 19) {
                Text("Inventory")
                    .font(.bold(size: 35))
                    .leftAligned()
                    .padding(.leading, 6)
                    .padding(.horizontal, 28)

                TextFieldRounded(title: nil,
                                 placeHolder: "Search your inventory",
                                 style: .white,
                                 text: $searchText)
                    .padding(.horizontal, 22)

                ScrollView(.vertical, showsIndicators: false) {
                    if let resultCount = store.state.inventorySearchResults?.count, !searchText.isEmpty {
                        Text("\(resultCount) Results:")
                            .font(.bold(size: 12))
                            .leftAligned()
                            .padding(.horizontal, 28)
                    }

                    ForEach(searchText.isEmpty ? store.state.inventoryItems : (store.state.inventorySearchResults ?? [])) { inventoryItem in
                        ListItem(title: inventoryItem.name,
                                 imageURL: inventoryItem.imageURL ?? "",
                                 accessoryView: nil) {
                            selectedInventoryItemId = inventoryItem.id
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 6)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .frame(maxWidth: UIScreen.main.bounds.width)
        }
        .navigationbarHidden()
        .onChange(of: searchText) { searchText in
            store.send(.main(action: .getInventorySearchResults(searchTerm: searchText)))
        }
    }

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
