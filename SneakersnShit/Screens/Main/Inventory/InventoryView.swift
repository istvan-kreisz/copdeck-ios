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
    @State private var image: UIImage?
    @State private var username: String = ""

    @Binding var shouldShowTabBar: Bool
    @Binding var settingsPresented: Bool

    @ObservedObject var viewRouter: ViewRouter

    var selectedStack: Stack? {
        stacks[safe: selectedStackIndex]
    }

    var supportedTrayActions: [TrayAction] {
        ((selectedStackIndex == 0) ? [.deleteItems] : [.deleteItems, .deleteStack, .unstackItems])
    }

    var inventoryItems: [InventoryItem] {
        store.state.inventoryItems
    }

    var stacks: [Stack] {
        store.state.stacks.sortedByDate()
    }

    func updateBestPrices() {
        bestPrices = store.state.inventoryItems.map { (inventoryItem: InventoryItem) in (inventoryItem.id, bestPrice(for: inventoryItem)) }
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
                .filter { $0.status != .Sold }
                .compactMap { bestPrices[$0.id]?.price }
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
        Group {
            let pageCount = Binding<Int>(get: { store.state.stacks.count }, set: { _ in })
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
            NavigationLink(destination: editedStack.map { editedStack in SelectStackItemsView(showView: showEditedStack,
                                                                                              stack: editedStack,
                                                                                              inventoryItems: $store.state.inventoryItems,
                                                                                              requestInfo: store.state.requestInfo,
                                                                                              saveChanges: { updatedStackItems in
                                                                                                  var updatedStack = editedStack
                                                                                                  updatedStack.items = updatedStackItems
                                                                                                  store
                                                                                                      .send(.main(action: .updateStack(stack: updatedStack)))
                                                                                              }) },
            isActive: showEditedStack) { EmptyView() }

            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .center, spacing: 30) {
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

                    VStack(spacing: 5) {
                        ProfilePhotoSelectorView(showImagePicker: $showImagePicker, profileImageURL: $store.state.profileImageURL)
                        TextFieldUnderlined(text: $username,
                                            placeHolder: "username",
                                            color: .customText1,
                                            dismissKeyboardOnReturn: false,
                                            icon: nil,
                                            keyboardType: .default,
                                            isSecureField: false,
                                            textAlignment: TextAlignment.center,
                                            trailingPadding: 0,
                                            addLeadingPadding: false,
                                            onFinishedEditing: updateUsername)
                            .frame(width: 150)
                    }

                    HStack {
                        VStack(spacing: 2) {
                            Text(inventoryValue?.asString ?? "-")
                                .font(.bold(size: 20))
                                .foregroundColor(.customText1)
                            Text("Inventory Value")
                                .font(.regular(size: 15))
                                .foregroundColor(.customText2)
                        }
                        Spacer()
                        VStack(spacing: 2) {
                            Text("\(inventoryItems.count)")
                                .font(.bold(size: 20))
                                .foregroundColor(.customText1)
                            Text("Inventory Size")
                                .font(.regular(size: 15))
                                .foregroundColor(.customText2)
                        }
                    }
                    .withDefaultPadding(padding: .horizontal)
                    .padding(.top, 25)
                }
                .withDefaultPadding(padding: .horizontal)
                .padding(.bottom, 22)

                VStack(alignment: .leading, spacing: 19) {
                    HStack(alignment: .center, spacing: 13) {
                        TextFieldRounded(title: nil,
                                         placeHolder: "Search your inventory",
                                         style: .white,
                                         text: $searchText)
                        RoundedButton<EmptyView>(text: "Edit",
                                                 width: 80,
                                                 height: 32,
                                                 color: .customBlue,
                                                 accessoryView: nil,
                                                 tapped: { isEditing.toggle() })

                        Button(action: {
                            showFilters = true
                        }, label: {
                            ZStack {
                                Circle()
                                    .fill(Color.customOrange)
                                    .frame(width: 32, height: 32)
                                Image("filter")
                                    .renderingMode(.template)
                                    .frame(height: 24)
                                    .foregroundColor(.customWhite)
                            }
                        })
                    }
                    .withDefaultPadding(padding: .horizontal)

                    ScrollableSegmentedControl(selectedIndex: $selectedStackIndex,
                                               titles: stackTitles,
                                               button: .init(title: "New Stack", tapped: { showAddNewStackAlert = true }))
                        .withDefaultPadding(padding: .horizontal)

                    PagerView(pageCount: pageCount, currentIndex: $selectedStackIndex) {
                        ForEach(stacks) { (stack: Stack) in
                            let isSelected = Binding<Bool>(get: { stack.id == selectedStack?.id }, set: { _ in })

                            StackView(stack: stack,
                                      searchText: $searchText,
                                      filters: filters,
                                      inventoryItems: $store.state.inventoryItems,
                                      selectedInventoryItemId: $selectedInventoryItemId,
                                      isEditing: $isEditing,
                                      selectedInventoryItems: $selectedInventoryItems,
                                      isSelected: isSelected,
                                      bestPrices: $bestPrices,
                                      requestInfo: store.state.requestInfo,
                                      didTapEditStack: stack.id == "all" ? nil : {
                                          editedStack = stack
                                      })
                        }
                    }
                }
                .padding(.top, 28)
                .frame(width: UIScreen.screenWidth)
                .background(Color.customBackground)
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
            .onChange(of: editedStack) { stack in
                shouldShowTabBar = stack == nil
            }
            .onChange(of: store.state.stacks) { stacks in
                if let indexOfNewStack = stacks.sortedByDate().firstIndex(where: { $0.id == newStackId }) {
                    newStackId = nil
                    selectedStackIndex = indexOfNewStack
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
        .withTabViewWrapper(viewRouter: viewRouter, store: store, backgroundColor: .customWhite, shouldShow: $shouldShowTabBar)
        .withTextFieldPopup(isShowing: $showAddNewStackAlert,
                            title: "Add new stack",
                            subtitle: nil,
                            placeholder: "Enter your stack's name",
                            actionTitle: "Add Stack") { stackName in
                guard !stackName.isEmpty else { return }
                addNewStack(withName: stackName)
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
            InventoryView(shouldShowTabBar: .constant(true), settingsPresented: .constant(false), viewRouter: ViewRouter())
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
