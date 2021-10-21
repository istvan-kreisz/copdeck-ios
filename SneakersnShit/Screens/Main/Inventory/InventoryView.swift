//
//  InventoryView.swift
//  CopDeck
//
//  Created by István Kreisz on 3/30/21.
//

import SwiftUI
import Combine

struct InventoryView: View {
    enum Sheet {
        case settings, filters, imagePicker, sellerStats
    }

    @EnvironmentObject var store: InventoryStore
    @EnvironmentObject var globalStore: DerivedGlobalStore
    @State var navigationDestination: Navigation<NavigationDestination> = .init(destination: .empty, show: false)

    @State private var searchText = ""
    @State private var isEditing = false
    @State private var selectedInventoryItems: [InventoryItem] = []
    @State private var selectedStackIndex = 0
    @State private var showAddNewStackAlert = false
    @State private var bestPrices: [String: ListingPrice] = [:]
    @State private var newStackId: String?
    @State var username: String = ""
    @State private var sharedStack: Stack?
    @State private var showSnackBar = false

    @Binding var shouldShowTabBar: Bool

    @ObservedObject var viewRouter: ViewRouter

    @State var popup: (String, String)? = nil

    @State private var presentedSheet: Sheet? = nil

    var selectedStack: Stack? {
        stacks[safe: selectedStackIndex]
    }

    var supportedTrayActions: [TrayAction] {
        (selectedStackIndex == 0) ? [TrayAction.deleteItems] : [TrayAction.deleteItems, TrayAction.deleteStack, TrayAction.unstackItems]
    }

    var inventoryItems: [InventoryItem] {
        store.state.inventoryItems
    }

    var stacks: [Stack] {
        store.state.stacks.sortedByDate()
    }

    var editedStack: Stack? {
        guard case let .stack(stack) = navigationDestination.destination else { return nil }
        return stack.wrappedValue
    }

    var selectedInventoryItem: InventoryItem? {
        guard case let .inventoryItem(inventoryItem) = navigationDestination.destination else { return nil }
        return inventoryItem
    }

    func updateBestPrices() {
        bestPrices = store.state.inventoryItems
            .map { (inventoryItem: InventoryItem) -> (String, ListingPrice?) in (inventoryItem.id, bestPrice(for: inventoryItem)) }
            .reduce([:]) { (dict: [String: ListingPrice], element: (String, ListingPrice?)) in
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
        if let currencyCode = bestPrices.values.first?.price.currencyCode {
            let sum = inventoryItems
                .filter { (inventoryItem: InventoryItem) -> Bool in inventoryItem.status != .Sold }
                .compactMap { (inventoryItem: InventoryItem) -> Double? in bestPrices[inventoryItem.id]?.price.price }
                .sum()
            return PriceWithCurrency(price: sum, currencyCode: currencyCode)
        } else {
            return nil
        }
    }

    private func bestPrice(for inventoryItem: InventoryItem) -> ListingPrice? {
        if let itemId = inventoryItem.itemId, let item = ItemCache.default.value(itemId: itemId, settings: globalStore.globalState.settings) {
            return item.bestPrice(for: inventoryItem.size,
                                  feeType: globalStore.globalState.settings.bestPriceFeeType,
                                  priceType: globalStore.globalState.settings.bestPricePriceType,
                                  stores: globalStore.globalState.settings.displayedStores)
        } else {
            return nil
        }
    }

    var body: some View {
        let showDetail = Binding<Bool>(get: { navigationDestination.show },
                                       set: { show in show ? navigationDestination.display() : navigationDestination.hide() })
        let showSharePopup = Binding<Bool>(get: { sharedStack != nil },
                                           set: { sharedStack = $0 ? sharedStack : nil })
        let showPopup = Binding<Bool>(get: { popup != nil }, set: { show in popup = show ? popup : nil })
        let showSheet = Binding<Bool>(get: { presentedSheet != nil }, set: { show in presentedSheet = show ? presentedSheet : nil })
        let settingsPresented = Binding<Bool>(get: { presentedSheet == .settings }, set: { show in presentedSheet = show ? .settings : nil })
        let showImagePicker = Binding<Bool>(get: { presentedSheet == .imagePicker }, set: { show in presentedSheet = show ? .imagePicker : nil })
        let showSellerStats = Binding<Bool>(get: { presentedSheet == .sellerStats }, set: { show in presentedSheet = show ? .sellerStats : nil })
        let showFilters = Binding<Bool>(get: { presentedSheet == .filters }, set: { show in presentedSheet = show ? .filters : nil })
        let selectedInventoryItemBinding = Binding<InventoryItem?>(get: { selectedInventoryItem },
                                                                   set: { inventoryItem in
                                                                       if let inventoryItem = inventoryItem {
                                                                           navigationDestination += .inventoryItem(inventoryItem)
                                                                       } else {
                                                                           navigationDestination.hide()
                                                                       }
                                                                   })
        let selectedStackBinding = Binding<Stack>(get: { selectedStack ?? .empty }, set: { _ in })

        Group {
            let stackTitles = Binding<[String]>(get: { stacks.map { (stack: Stack) in stack.name } }, set: { _ in })
            let actionsTrayActions = Binding<[ActionConfig]>(get: {
                                                                 supportedTrayActions
                                                                     .map { action in
                                                                         .init(name: action.name) { didTapActionsTray(action: action) }
                                                                     }
                                                             },
                                                             set: { _ in })
            let filters = Binding<Filters>(get: { globalStore.globalState.settings.filters }, set: { _ in })

            NavigationLink(destination: Destination(navigationDestination: $navigationDestination,
                                                    bestPrices: $bestPrices,
                                                    selectedStack: selectedStackBinding).navigationbarHidden(),
                           isActive: showDetail) {
                EmptyView()
            }

            VerticalListView(bottomPadding: 0, spacing: 0, listRowStyling: .none) {
                InventoryHeaderView(settingsPresented: settingsPresented,
                                    showImagePicker: showImagePicker,
                                    showSellerStats: showSellerStats,
                                    profileImageURL: $store.state.profileImageURL,
                                    username: $username,
                                    textBox1: .init(title: "Inventory Value", text: inventoryValue?.asString ?? "-"),
                                    textBox2: .init(title: "Inventory Size", text: "\(inventoryItems.count)"),
                                    facebookURL: nil,
                                    updateUsername: updateUsername,
                                    linkFacebookProfile: globalStore.globalState.user?.facebookProfileURL == nil ? linkFacebookProfile : nil)

                ScrollableSegmentedControl(selectedIndex: $selectedStackIndex,
                                           titles: stackTitles,
                                           button: .init(title: "New Stack", tapped: { showAddNewStackAlert = true }))
                    .padding(.bottom, 8)
                    .padding(.top, -6)
                    .listRow()

                if let stack = stacks[safe: selectedStackIndex] {
                    let isSelected = Binding<Bool>(get: { stack.id == selectedStack?.id }, set: { _ in })

                    StackView(stack: stack,
                              searchText: $searchText,
                              filters: filters,
                              inventoryItems: $store.state.inventoryItems,
                              selectedInventoryItem: selectedInventoryItemBinding,
                              isEditing: $isEditing,
                              showFilters: showFilters,
                              selectedInventoryItems: $selectedInventoryItems,
                              isSelected: isSelected,
                              bestPrices: $bestPrices,
                              requestInfo: globalStore.globalState.requestInfo,
                              emptyStateConfig: (stack.id == "all" ?
                                  StackView.EmptyStateConfig.init(title: "Your inventory is empty",
                                                                  buttonTitle: "Use the search tab to add items") {
                                      viewRouter.currentPage = .search
                                  } :
                                  StackView.EmptyStateConfig.init(title: "Your stack is empty",
                                                                  buttonTitle: "Start adding items") {
                                      navigationDestination += .selectStackItems(stack)
                                  }),
                              didTapEditStack: stack.id == "all" ? nil : {
                                  navigationDestination += .stack(selectedStackBinding)
                              }, didTapShareStack: stack.id == "all" ? nil : {
                                  sharedStack = stack
                              })
                        .listRow()
                }
                Color.clear.padding(.bottom, Styles.tabScreenBottomPadding)
                    .listRow()
                GeometryReader { proxy in
                    if proxy.frame(in: .global).minY < UIScreen.screenHeight {
                        Color.customBackground.frame(width: UIScreen.screenWidth + 30, height: UIScreen.screenHeight - proxy.frame(in: .global).minY)
                            .listRow()
                    }
                }
                .offset(x: -30)
                .listRow()
            }
            .withFloatingButton(button: EditInventoryTray(actions: actionsTrayActions)
                .padding(.bottom, UIApplication.shared.safeAreaInsets().bottom)
                .opacity(isEditing ? 1.0 : 0.0))
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
                        if editedStack != nil {
                            navigationDestination += .stack(selectedStackBinding)
                        } else {
                            navigationDestination.hide()
                        }
                    }
                }
            }
            .onChange(of: store.state.inventoryItems) { _ in
                updateBestPrices()
            }
            .onChange(of: globalStore.globalState.user?.name) { newValue in
                self.username = newValue ?? ""
            }
            .onChange(of: globalStore.globalState.user?.settings) { _ in
                updateBestPrices()
            }
            .onReceive(ItemCache.default.updatedPublisher.debounce(for: .milliseconds(500), scheduler: RunLoop.main).prepend(())) { _ in
                updateBestPrices()
            }
            .sheet(isPresented: showSheet) {
                switch presentedSheet {
                case .settings:
                    SettingsView(settings: globalStore.globalState.settings, isPresented: settingsPresented)
                        .environmentObject(DerivedGlobalStore.default)
                case .filters:
                    FiltersModal(settings: globalStore.globalState.settings, isPresented: showFilters)
                        .environmentObject(DerivedGlobalStore.default)
                case .imagePicker:
                    ImagePickerView(showPicker: showSheet, selectionLimit: 1) { (images: [UIImage]) in
                        images.first.map { self.store.send(.main(action: .uploadProfileImage(image: $0))) }
                    }
                case .sellerStats:
                    SellerStatsView(inventoryItems: inventoryItems, currency: globalStore.globalState.settings.currency,
                                    exchangeRates: globalStore.globalState.exchangeRates ?? .default)
                case .none:
                    EmptyView()
                }
            }
        }
        .withTabViewWrapper(viewRouter: viewRouter, store: InventoryStore.default, backgroundColor: .customWhite, shouldShow: $shouldShowTabBar)
        .withTextFieldPopup(isShowing: $showAddNewStackAlert,
                            title: "Add new stack",
                            subtitle: nil,
                            placeholder: "Enter your stack's name",
                            actionTitle: "Add Stack") { stackName in
            guard !stackName.isEmpty else { return }
            addNewStack(withName: stackName)
        }
        .withPopup {
            if let stack = sharedStack {
                Popup(isShowing: showSharePopup,
                      title: "Share stack",
                      subtitle: "Share this link with anyone to show them what's in your stack. The link opens a webpage so whoever you share it with doesn't need to have the app downloaded.",
                      firstAction: .init(name: "Done", tapped: { sharedStack = nil }),
                      secondAction: nil) {
                    StackShareSettingsView(linkURL: sharedStack?.linkURL(userId: globalStore.globalState.user?.id ?? "") ?? "",
                                           stack: .constant(stack),
                                           isPublic: stack.isPublic ?? false,
                                           isPublished: stack.isPublished ?? false,
                                           includeTitle: false) { title in
                        showSnackBar = true
                    } showPopup: { title, subtitle in
                        popup = (title, subtitle)
                    } updateStack: { stack in
                        store.send(.main(action: .updateStack(stack: stack)))
                    }
                }
            }
        }
        .withPopup {
            Popup<EmptyView>(isShowing: showPopup,
                             title: popup.map { $0.0 } ?? "",
                             subtitle: popup.map { $0.1 } ?? "",
                             firstAction: .init(name: "Okay", tapped: { popup = nil }),
                             secondAction: nil)
        }
        .withSnackBar(text: "Link Copied", shouldShow: $showSnackBar)
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
                                                        created: Date.serverDate,
                                                        updated: Date.serverDate,
                                                        publishedDate: nil))))
    }

    private func updateUsername() {
        store.send(.main(action: .updateUsername(username: username)))
    }

    private func linkFacebookProfile() {
        store.send(.authentication(action: .signInWithFacebook(referralCode: nil)))
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

extension InventoryView {
    enum NavigationDestination {
        case inventoryItem(InventoryItem), stack(Binding<Stack>), selectStackItems(Stack), empty
    }

    struct Destination: View {
        @EnvironmentObject var store: InventoryStore
        @EnvironmentObject var globalStore: DerivedGlobalStore

        @Binding var navigationDestination: Navigation<NavigationDestination>
        @Binding var bestPrices: [String: ListingPrice]
        @Binding var selectedStack: Stack

        var editedStack: Stack? {
            guard case let .stack(stack) = navigationDestination.destination else { return nil }
            return stack.wrappedValue
        }

        var body: some View {
            let filters = Binding<Filters>(get: { globalStore.globalState.settings.filters }, set: { _ in })

            switch navigationDestination.destination {
            case let .inventoryItem(inventoryItem):
                InventoryItemDetailView(inventoryItem: inventoryItem, isInSharedStack: selectedStack.isShared) { navigationDestination.hide() }
            case let .stack(stack):
                StackDetailView(stack: stack,
                                inventoryItems: $store.state.inventoryItems,
                                bestPrices: $bestPrices,
                                filters: filters,
                                linkURL: editedStack?.linkURL(userId: globalStore.globalState.user?.id ?? "") ?? "",
                                requestInfo: globalStore.globalState.requestInfo,
                                shouldDismiss: { navigationDestination.hide() },
                                saveChanges: { updatedStackItems in
                                    if var updatedStack = editedStack {
                                        updatedStack.items = updatedStackItems
                                        store.send(.main(action: .updateStack(stack: updatedStack)))
                                    }
                                }, deleteStack: {
                                    navigationDestination.hide()
                                    if let editedStack = editedStack {
                                        store.send(.main(action: .deleteStack(stack: editedStack)))
                                    }
                                })
            case let .selectStackItems(stack):
                SelectStackItemsView(stack: stack,
                                     inventoryItems: store.state.inventoryItems,
                                     requestInfo: globalStore.globalState.requestInfo,
                                     shouldDismiss: { navigationDestination.hide() },
                                     saveChanges: { updatedStackItems in
                                         var updatedStack = stack
                                         updatedStack.items = updatedStackItems
                                         store.send(.main(action: .updateStack(stack: updatedStack)))
                                     })
            case .empty:
                EmptyView()
            }
        }
    }
}
