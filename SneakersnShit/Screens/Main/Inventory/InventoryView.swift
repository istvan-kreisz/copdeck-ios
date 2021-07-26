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

    @Binding var shouldShowTabBar: Bool
    @State var settingsPresented = false

    var inventoryItems: [InventoryItem] {
        searchText.isEmpty ? store.state.inventoryItems : (store.state.inventorySearchResults ?? [])
    }

    var body: some View {
        let isEditingInventoryItem = Binding<Bool>(get: { selectedInventoryItemId != nil },
                                                   set: { selectedInventoryItemId = $0 ? selectedInventoryItemId : nil })
        ForEach(store.state.inventoryItems) { inventoryItem in
            NavigationLink(destination: InventoryItemDetailView(inventoryItem: inventoryItem,
                                                                isEditingInventoryItem: isEditingInventoryItem),
                tag: inventoryItem.id,
                selection: $selectedInventoryItemId) { EmptyView() }
        }
        VStack(alignment: .leading, spacing: 19) {
            HStack {
                Text("Inventory")
                    .font(.bold(size: 35))
                    .leftAligned()
                    .padding(.leading, 6)
                Spacer()
                Button(action: {
                    settingsPresented = true
                }, label: {
                    ZStack {
                        Circle().stroke(Color.customAccent1, lineWidth: 2)
                            .frame(width: 38, height: 38)
                        Image("cog")
                            .renderingMode(.template)
                            .frame(height: 17)
                            .foregroundColor(.customBlack)
                    }
                })
            }
            .withDefaultPadding(padding: .horizontal)

            HStack(alignment: .center, spacing: 13) {
                TextFieldRounded(title: nil,
                                 placeHolder: "Search your inventory",
                                 style: .white,
                                 text: $searchText)
                RoundedButton(text: "Edit",
                              size: .init(width: 80, height: 32),
                              color: .customBlue,
                              accessoryView: nil,
                              tapped: { isEditing.toggle() })
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
                Color.clear.padding(.bottom, 130)
            }
        }
        .withFloatingButton(button: EditInventoryTray(didTapCancel: {
            isEditing = false
        }, didTapDelete: {
            deleteFromInventory(inventoryItems: selectedInventoryItems)
            isEditing = false
        })
            .padding(.bottom, UIApplication.shared.safeAreaInsets().bottom)
            .if(!isEditing) { $0.hidden() })
        .onChange(of: searchText) { searchText in
            store.send(.main(action: .getInventorySearchResults(searchTerm: searchText)))
        }
        .onChange(of: isEditing) { editing in
            shouldShowTabBar = !editing
            selectedInventoryItems = []
        }
        .sheet(isPresented: $settingsPresented) {
            SettingsView()
                .environmentObject(store)
        }
    }

    func deleteFromInventory(inventoryItems: [InventoryItem]) {
        store.send(.main(action: .removeFromInventory(inventoryItems: inventoryItems)))
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            InventoryView(shouldShowTabBar: .constant(true))
                .environmentObject(AppStore.default)
        }
    }
}
