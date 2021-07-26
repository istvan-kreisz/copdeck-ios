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
    @State private var isEditing = false
    @State private var selectedInventoryItems: [InventoryItem] = []

    var inventoryItems: [InventoryItem] {
        searchText.isEmpty ? store.state.inventoryItems : (store.state.inventorySearchResults ?? [])
    }

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

                HStack(alignment: .center, spacing: 13) {
                    TextFieldRounded(title: nil,
                                     placeHolder: "Search your inventory",
                                     style: .white,
                                     text: $searchText)
                    RoundedButton(text: "Edit",
                                  size: .init(width: 80, height: 32),
                                  color: .customBlue,
                                  accessoryView: nil,
                                  tapped: {
                                      isEditing.toggle()
                                  })
//                        .padding(.top, 15)
                }
                .withDefaultPadding(padding: .horizontal)

                ScrollView(.vertical, showsIndicators: false) {
                    Text("\(inventoryItems.count) \(searchText.isEmpty ? "Items:" : "Results:")")
                        .font(.bold(size: 12))
                        .leftAligned()
                        .padding(.horizontal, 28)

                    ForEach(inventoryItems) { inventoryItem in
                        InventoryListItem(inventoryItem: inventoryItem,
                                          selectedInventoryItemId: $selectedInventoryItemId,
                                          isEditing: $isEditing,
                                          isSelected: selectedInventoryItems.contains(where: { $0.id == inventoryItem.id })) {
                                if selectedInventoryItems.contains(where: { $0.id == inventoryItem.id }) {
                                    selectedInventoryItems = selectedInventoryItems.filter { $0.id != inventoryItem.id }
                                } else {
                                    selectedInventoryItems.append(inventoryItem)
                                }
                        }
                    }
                    .withDefaultPadding(padding: .horizontal)
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
