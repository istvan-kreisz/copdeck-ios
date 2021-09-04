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
    @State private var showFilters = false
    @State private var selectedInventoryItems: [InventoryItem] = []
    @State private var selectedStackIndex = 0
    @State private var editedStack: Stack?
    @State private var showAddNewStackAlert = false
    @State private var bestPrices: [String: PriceWithCurrency] = [:]
    @State private var newStackId: String?
    @State private var showImagePicker = false
    @State var username: String = ""
    @State private var sharedStack: Stack?
    @State private var showSnackBar = false

    @Binding var shouldShowTabBar: Bool
    @Binding var settingsPresented: Bool

    @ObservedObject var viewRouter: ViewRouter

    var selectedStack: Stack? {
        stacks[safe: selectedStackIndex]
    }

    var supportedTrayActions: [TrayAction] {
        ((selectedStackIndex == 0) ? [TrayAction.deleteItems] : [TrayAction.deleteItems, TrayAction.deleteStack, TrayAction.unstackItems])
    }

    var inventoryItems: [InventoryItem] {
        store.state.inventoryItems
    }

    var stacks: [Stack] {
        store.state.stacks.sortedByDate()
    }

    func updateBestPrices() {
        bestPrices = store.state.inventoryItems
            .map { (inventoryItem: InventoryItem) -> (String, PriceWithCurrency?) in (inventoryItem.id, bestPrice(for: inventoryItem)) }
            .reduce([:]) { (dict: [String: PriceWithCurrency], element: (String, PriceWithCurrency?)) in
                if let price = element.1 {
                    var newDict = dict
                    newDict[element.0] = price
                    return newDict
                } else {
                    return dict
                }
            }
    }

    var inventoryValue: PriceWithCurrency? {
        if let currencyCode = bestPrices.values.first?.currencyCode {
            let sum = inventoryItems
                .filter { (inventoryItem: InventoryItem) -> Bool in inventoryItem.status != .Sold }
                .compactMap { (inventoryItem: InventoryItem) -> Double? in bestPrices[inventoryItem.id]?.price }
                .sum()
            return PriceWithCurrency(price: sum, currencyCode: currencyCode)
        } else {
            return nil
        }
    }

    private func bestPrice(for inventoryItem: InventoryItem) -> PriceWithCurrency? {
        if let itemId = inventoryItem.itemId, let item = ItemCache.default.value(itemId: itemId, settings: store.state.settings) {
            return item.bestPrice(for: inventoryItem.size,
                                  feeType: store.state.settings.bestPriceFeeType,
                                  priceType: store.state.settings.bestPricePriceType,
                                  stores: store.state.settings.displayedStores)
        } else {
            return nil
        }
    }

    var body: some View {
        let showCopyLink = Binding<Bool>(get: { sharedStack != nil },
                                         set: { sharedStack = $0 ? sharedStack : nil })
        Group {
            let stackTitles = Binding<[String]>(get: { stacks.map { (stack: Stack) in stack.name } }, set: { _ in })
            let actionsTrayActions = Binding<[ActionConfig]>(get: {
                                                                 supportedTrayActions
                                                                     .map { action in
                                                                         .init(name: action.name) { didTapActionsTray(action: action) }
                                                                     }
                                                             },
                                                             set: { _ in })
            let showEditedStack = Binding<Bool>(get: { editedStack?.id != nil },
                                                set: { editedStack = $0 ? editedStack : nil })
            let filters = Binding<Filters>(get: { store.state.settings.filters }, set: { _ in })

            NavigationLink(destination: EmptyView()) {
                EmptyView()
            }
            ForEach(inventoryItems) { (inventoryItem: InventoryItem) in
                NavigationLink(destination: InventoryItemDetailView(inventoryItem: inventoryItem) { selectedInventoryItemId = nil },
                               tag: inventoryItem.id,
                               selection: $selectedInventoryItemId) { EmptyView() }
            }
            NavigationLink(destination: editedStack.map { editedStack in
                StackDetailView(stack: .constant(editedStack),
                            inventoryItems: $store.state.inventoryItems,
                            bestPrices: $bestPrices,
                            showView: showEditedStack,
                            filters: filters,
                            linkURL: editedStack.linkURL(userId: store.state.user?.id ?? ""),
                            requestInfo: store.state.requestInfo,
                            saveChanges: { updatedStackItems in
                                var updatedStack = editedStack
                                updatedStack.items = updatedStackItems
                                store.send(.main(action: .updateStack(stack: updatedStack)))
                            })
            },
            isActive: showEditedStack) { EmptyView() }

            VerticalListView(bottomPadding: 0, spacing: 0, listRowStyling: .none) {
                InventoryHeaderView(settingsPresented: $settingsPresented,
                                    showImagePicker: $showImagePicker,
                                    profileImageURL: $store.state.profileImageURL,
                                    username: $username,
                                    textBox1: .init(title: "Inventory Value", text: inventoryValue?.asString ?? "-"),
                                    textBox2: .init(title: "Inventory Size", text: "\(inventoryItems.count)"),
                                    updateUsername: updateUsername)

                ScrollableSegmentedControl(selectedIndex: $selectedStackIndex,
                                           titles: stackTitles,
                                           button: .init(title: "New Stack", tapped: { showAddNewStackAlert = true }))
                    .padding(.bottom, 12)
                    .padding(.top, -2)
                    .listRow()

                if let stack = stacks[safe: selectedStackIndex] {
                    let isSelected = Binding<Bool>(get: { stack.id == selectedStack?.id }, set: { _ in })

                    StackView(stack: stack,
                              searchText: $searchText,
                              filters: filters,
                              inventoryItems: $store.state.inventoryItems,
                              selectedInventoryItemId: $selectedInventoryItemId,
                              isEditing: $isEditing,
                              showFilters: $showFilters,
                              selectedInventoryItems: $selectedInventoryItems,
                              isSelected: isSelected,
                              bestPrices: $bestPrices,
                              requestInfo: store.state.requestInfo,
                              didTapEditStack: stack.id == "all" ? nil : {
                                  editedStack = stack
                              }, didTapShareStack: stack.id == "all" ? nil : {
                                  sharedStack = stack
                              })
                        .padding(.top, 5)
                        .listRow()
                }
                Color.clear.padding(.bottom, Styles.tabScreenBottomPadding)
                    .listRow()
            }
            .withFloatingButton(button: EditInventoryTray(actions: actionsTrayActions)
                .padding(.bottom, UIApplication.shared.safeAreaInsets().bottom)
                .if(!isEditing) { $0.hidden() })
            .onChange(of: isEditing) { editing in
                shouldShowTabBar = !editing
                selectedInventoryItems = []
            }
            .onChange(of: selectedStackIndex) { stackIndex in
                isEditing = false
            }
            .onChange(of: store.state.stacks) { stacks in
                if let indexOfNewStack = stacks.sortedByDate().firstIndex(where: { $0.id == newStackId }) {
                    newStackId = nil
                    selectedStackIndex = indexOfNewStack
                }
                if let updatedEditedStack = stacks.first(where: { $0.id == editedStack?.id }) {
                    if editedStack != updatedEditedStack {
                        editedStack = updatedEditedStack
                    }
                }
            }
            .onChange(of: store.state.inventoryItems) { _ in
                updateBestPrices()
            }
            .onChange(of: store.state.user?.name) { newValue in
                self.username = newValue ?? ""
            }
            .onChange(of: store.state.user?.settings) { _ in
                updateBestPrices()
            }
            .onReceive(ItemCache.default.updatedPublisher.debounce(for: .milliseconds(500), scheduler: RunLoop.main).prepend(())) { _ in
                updateBestPrices()
            }
            .sheet(isPresented: $settingsPresented) {
                SettingsView(settings: store.state.settings, isPresented: $settingsPresented)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showFilters) {
                FiltersModal(settings: store.state.settings, isPresented: $showFilters)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(sourceType: .photoLibrary) { image in
                    self.store.send(.main(action: .uploadProfileImage(image: image)))
                }
            }
        }
        .withTabViewWrapper(viewRouter: viewRouter, store: store, backgroundColor: .customBackground, shouldShow: $shouldShowTabBar)
        .withSnackBar(text: "Link Copied", shouldShow: $showSnackBar)
        .withTextFieldPopup(isShowing: $showAddNewStackAlert,
                            title: "Add new stack",
                            subtitle: nil,
                            placeholder: "Enter your stack's name",
                            actionTitle: "Add Stack") { stackName in
                guard !stackName.isEmpty else { return }
                addNewStack(withName: stackName)
        }
        .withPopup {
            CopyLinkPopup(isShowing: showCopyLink,
                          title: "Share stack",
                          subtitle: "Share this link with anyone to show them what's in your stack. The link opens a webpage so whoever you share it with doesn't need to have the app downloaded.",
                          linkURL: sharedStack?.linkURL(userId: store.state.user?.id ?? "") ?? "",
                          actionTitle: "Copy Link") { link in
                    if var updatedStack = sharedStack {
                        UIPasteboard.general.string = link
                        showSnackBar = true
                        updatedStack.isSharedViaLink = true
                        store.send(.main(action: .updateStack(stack: updatedStack)))
                    }
            }
        }
    }

    func didTapActionsTray(action: TrayAction) {
        switch action {
        case .deleteItems:
            store.send(.main(action: .removeFromInventory(inventoryItems: selectedInventoryItems)))
        case .unstackItems:
            selectedStack.map { (stack: Stack) in store.send(.main(action: .unstack(inventoryItems: selectedInventoryItems, stack: stack))) }
        case .deleteStack:
            selectedStack.map { (stack: Stack) in store.send(.main(action: .deleteStack(stack: stack))) }
        }
        isEditing = false
    }

    func addNewStack(withName name: String) {
        let newStackId = UUID().uuidString
        self.newStackId = newStackId
        store.send(.main(action: .addStack(stack: .init(id: newStackId,
                                                        name: name,
                                                        isPublished: false,
                                                        items: [],
                                                        created: Date().timeIntervalSince1970 * 1000,
                                                        updated: Date().timeIntervalSince1970 * 1000,
                                                        publishedDate: nil))))
    }

    private func updateUsername() {
        store.send(.main(action: .updateUsername(username: username)))
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            InventoryView(username: "", shouldShowTabBar: .constant(true), settingsPresented: .constant(false), viewRouter: ViewRouter())
                .environmentObject(AppStore.default)
        }
    }
}

extension InventoryView {
    enum TrayAction: String {
        case deleteItems
        case unstackItems
        case deleteStack

        var name: String {
            switch self {
            case .deleteItems:
                return "delete items"
            case .unstackItems:
                return "unstack items"
            case .deleteStack:
                return "delete stack"
            }
        }
    }
}
