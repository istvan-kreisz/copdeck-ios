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
    @State private var selectedStackIndex = 0

    @Binding var shouldShowTabBar: Bool
    @Binding var settingsPresented: Bool

    var inventoryItems: [InventoryItem] {
        searchText.isEmpty ? store.state.inventoryItems : (store.state.inventorySearchResults ?? [])
    }

    @State var titles = ["First", "Second", "Third"]

    var body: some View {
        let pageCount = Binding<Int>(get: { titles.count }, set: { _ in })
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
                    .foregroundColor(.customText1)
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

            ScrollableSegmentedControl(selectedIndex: $selectedStackIndex, titles: $titles)
                .withDefaultPadding(padding: .horizontal)
            PagerView(pageCount: pageCount, currentIndex: $selectedStackIndex) {
                ForEach(store.state.stacks) { stack in
                    StackView(searchText: $searchText,
                              inventoryItems: stack.inventoryItems(allInventoryItems: store.state.inventoryItems),
                              selectedInventoryItemId: $selectedInventoryItemId)
                }
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
            SettingsView(settings: store.state.settings, isPresented: $settingsPresented)
        }
    }

    func deleteFromInventory(inventoryItems: [InventoryItem]) {
        store.send(.main(action: .removeFromInventory(inventoryItems: inventoryItems)))
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            InventoryView(shouldShowTabBar: .constant(true), settingsPresented: .constant(false))
                .environmentObject(AppStore.default)
        }
    }
}
