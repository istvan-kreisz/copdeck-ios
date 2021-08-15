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
    @State private var editedStack: Stack?

    @Binding var shouldShowTabBar: Bool
    @Binding var settingsPresented: Bool

    var selectedStack: Stack? {
        store.state.stacks[safe: selectedStackIndex]
    }

    var supportedTrayActions: [TrayAction] {
        ((selectedStackIndex == 0) ? [.cancel, .delete] : [.cancel, .delete, .editStack, .unstack])
    }

    var body: some View {
        let pageCount = Binding<Int>(get: { store.state.stacks.count }, set: { _ in })
        let stackTitles = Binding<[String]>(get: { store.state.stacks.map { $0.name } }, set: { _ in })
        let isEditingInventoryItem = Binding<Bool>(get: { selectedInventoryItemId != nil },
                                                   set: { selectedInventoryItemId = $0 ? selectedInventoryItemId : nil })
        let actionsTrayActions = Binding<[EditInventoryTray.ActionConfig]>(get: {
                                                                               supportedTrayActions
                                                                                   .map { action in
                                                                                       .init(name: action.name) { didTapActionsTray(action: action) }
                                                                                   }
                                                                           },
                                                                           set: { _ in })
        let showEditedStack = Binding<Bool>(get: { editedStack?.id != nil },
                                            set: { editedStack = $0 ? editedStack : nil })

        ForEach(store.state.inventoryItems) { inventoryItem in
            NavigationLink(destination: InventoryItemDetailView(inventoryItem: inventoryItem,
                                                                isEditingInventoryItem: isEditingInventoryItem),
                           tag: inventoryItem.id,
                           selection: $selectedInventoryItemId) { EmptyView() }
        }
        if let editedStack = editedStack {
            NavigationLink(destination: EmptyView(),
                           isActive: showEditedStack) { EmptyView() }
                .isDetailLink(false)
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

            ScrollableSegmentedControl(selectedIndex: $selectedStackIndex, titles: stackTitles, button: .init(title: "New Stack", tapped: addNewStack))
                .withDefaultPadding(padding: .horizontal)
            PagerView(pageCount: pageCount, currentIndex: $selectedStackIndex) {
                ForEach(store.state.stacks) { stack in
                    StackView(searchText: $searchText,
                              inventoryItems: stack.inventoryItems(allInventoryItems: store.state.inventoryItems),
                              selectedInventoryItemId: $selectedInventoryItemId,
                              isEditing: $isEditing,
                              selectedInventoryItems: $selectedInventoryItems)
                }
            }
        }
        .withFloatingButton(button: EditInventoryTray(actions: actionsTrayActions)
            .padding(.bottom, UIApplication.shared.safeAreaInsets().bottom)
            .if(!isEditing) { $0.hidden() })
        .onChange(of: searchText) { searchText in
            guard let stack = selectedStack else { return }
            store.send(.main(action: .getInventorySearchResults(searchTerm: searchText, stack: stack)))
        }
        .onChange(of: isEditing) { editing in
            shouldShowTabBar = !editing
            selectedInventoryItems = []
        }
        .onChange(of: selectedStackIndex) { stackIndex in
            isEditing = false
        }
        .sheet(isPresented: $settingsPresented) {
            SettingsView(settings: store.state.settings, isPresented: $settingsPresented)
        }
    }

    func didTapActionsTray(action: TrayAction) {
        switch action {
        case .cancel:
            break
        case .delete:
            store.send(.main(action: .removeFromInventory(inventoryItems: selectedInventoryItems)))
        case .editStack:
            editedStack = selectedStack
        case .unstack:
            break
        }
        isEditing = false
    }

    func addNewStack() {
        store.send(.main(action: .addStack(stack: .init(id: UUID().uuidString, name: "new", isPublished: false, items: []))))
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

extension InventoryView {
    enum TrayAction: String {
        case cancel
        case delete
        case editStack
        case unstack

        var name: String {
            switch self {
            case .cancel, .delete, .unstack:
                return rawValue
            case .editStack:
                return "edit stack"
            }
        }
    }
}
