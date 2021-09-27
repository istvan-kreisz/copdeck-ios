//
//  StackDetailView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/28/21.
//

import SwiftUI
import Combine

struct StackDetailView: View {
    @EnvironmentObject var store: AppStore

    @Binding var stack: Stack
    @Binding var inventoryItems: [InventoryItem]
    @Binding var bestPrices: [String: ListingPrice]
    @Binding var filters: Filters

    let linkURL: String
    let requestInfo: [ScraperRequestInfo]
    var shouldDismiss: () -> Void
    let saveChanges: ([StackItem]) -> Void
    let deleteStack: () -> Void

    @State var navigationDestination: Navigation<NavigationDestination> = .init(destination: .empty, show: false)

    @State var name: String
    @State var caption: String

    @State var popup: (String, String)? = nil

    @State private var showSnackBar = false
    @State private var popupIndex: Int? = nil

    @State private var showCaption: Bool

    var allStackItems: [InventoryItem] {
        stack.inventoryItems(allInventoryItems: inventoryItems, filters: filters, searchText: "")
    }

    var stackValue: PriceWithCurrency? {
        if let currencyCode = bestPrices.values.first?.price.currencyCode {
            let sum = allStackItems
                .filter { $0.status != .Sold }
                .compactMap { bestPrices[$0.id]?.price.price }
                .sum()
            return PriceWithCurrency(price: sum, currencyCode: currencyCode)
        } else {
            return nil
        }
    }

    var selectedInventoryItem: InventoryItem? {
        guard case let .inventoryItem(inventoryItem) = navigationDestination.destination else { return nil }
        return inventoryItem
    }

    init(stack: Binding<Stack>,
         inventoryItems: Binding<[InventoryItem]>,
         bestPrices: Binding<[String: ListingPrice]>,
         filters: Binding<Filters>,
         linkURL: String,
         requestInfo: [ScraperRequestInfo],
         shouldDismiss: @escaping () -> Void,
         saveChanges: @escaping ([StackItem]) -> Void,
         deleteStack: @escaping () -> Void) {
        self._stack = stack
        self._inventoryItems = inventoryItems
        self._bestPrices = bestPrices
        self._filters = filters
        self.linkURL = linkURL
        self.requestInfo = requestInfo
        self.shouldDismiss = shouldDismiss
        self.saveChanges = saveChanges
        self.deleteStack = deleteStack
        self._name = State<String>(initialValue: stack.wrappedValue.name)
        self._caption = State<String>(initialValue: stack.wrappedValue.caption ?? "")
        self._showCaption = State(initialValue: (stack.isPublished.wrappedValue ?? false) || (stack.isPublic.wrappedValue ?? false))
    }

    var body: some View {
        let showPopup = Binding<Bool>(get: { popup != nil }, set: { show in popup = show ? popup : nil })
        Group {
            let showDetail = Binding<Bool>(get: { navigationDestination.show },
                                           set: { show in show ? navigationDestination.display() : navigationDestination.hide() })
            let selectedInventoryItemBinding = Binding<InventoryItem?>(get: { selectedInventoryItem },
                                                                       set: { inventoryItem in
                                                                           if let inventoryItem = inventoryItem {
                                                                               navigationDestination += .inventoryItem(inventoryItem)
                                                                           } else {
                                                                               navigationDestination.hide()
                                                                           }
                                                                       })

            NavigationLink(destination: Destination(navigationDestination: $navigationDestination,
                                                    inventoryItems: $inventoryItems).navigationbarHidden(), isActive: showDetail) {
                    EmptyView()
            }

            VerticalListView(bottomPadding: Styles.tabScreenBottomPadding, spacing: 6, addHorizontalPadding: false) {
                NavigationBar(title: nil, isBackButtonVisible: true, style: .dark, shouldDismiss: shouldDismiss)
                    .withDefaultPadding(padding: .horizontal)

                VStack {
                    Text("Stack Stats".uppercased())
                        .font(.bold(size: 12))
                        .foregroundColor(.customText2)
                        .leftAligned()

                    HStack {
                        VStack(spacing: 2) {
                            Text(stackValue?.asString ?? "-")
                                .font(.bold(size: 20))
                                .foregroundColor(.customText1)
                            Text("Stack Value")
                                .font(.regular(size: 15))
                                .foregroundColor(.customText2)
                        }
                        Spacer()
                        VStack(spacing: 2) {
                            Text("\(allStackItems.count)")
                                .font(.bold(size: 20))
                                .foregroundColor(.customText1)
                            Text("Stack Size")
                                .font(.regular(size: 15))
                                .foregroundColor(.customText2)
                        }
                    }
                    .padding(.top, 5)
                }
                .asCard()
                .withDefaultPadding(padding: .horizontal)

                TextFieldRounded(title: "stack name",
                                 placeHolder: "name",
                                 style: .white,
                                 text: $name) { _ in nameChanged() }
                    .withDefaultPadding(padding: .horizontal)

                if showCaption {
                    TextFieldRounded(title: "caption (optional)",
                                     placeHolder: "caption",
                                     style: .white,
                                     text: $caption) { _ in captionChanged() }
                        .withDefaultPadding(padding: .horizontal)
                }

                StackShareSettingsView(linkURL: linkURL,
                                       stack: $stack,
                                       isPublic: stack.isPublic ?? false,
                                       isPublished: stack.isPublished ?? false,
                                       includeTitle: true) { title in
                        showSnackBar = true
                } showPopup: { title, subtitle in
                    popup = (title, subtitle)
                } updateStack: { stack in
                    showCaption = (stack.isPublished ?? false) || (stack.isPublic ?? false)
                    store.send(.main(action: .updateStack(stack: stack)))
                }
                .asCard()
                .withDefaultPadding(padding: .horizontal)

                ForEach(allStackItems) { (inventoryItem: InventoryItem) in
                    InventoryListItem(inventoryItem: inventoryItem,
                                      bestPrice: bestPrices[inventoryItem.id],
                                      selectedInventoryItem: selectedInventoryItemBinding,
                                      isSelected: false,
                                      isEditing: .constant(false),
                                      requestInfo: requestInfo) {}
                }
                .padding(.vertical, 2)
                .withDefaultPadding(padding: .horizontal)

                AccessoryButton(title: "Add / Delete Items",
                                color: .customBlue,
                                textColor: .customBlue,
                                width: 170,
                                imageName: "plus",
                                tapped: { navigationDestination += .itemSelector(stack) })
                    .leftAligned()
                    .withDefaultPadding(padding: .horizontal)
                    .buttonStyle(PlainButtonStyle())

                RoundedButton<EmptyView>(text: "Delete stack",
                                         width: 400,
                                         height: 50,
                                         maxSize: CGSize(width: UIScreen.screenWidth - Styles.horizontalMargin * 2, height: UIScreen.isSmallScreen ? 50 : 60),
                                         fontSize: UIScreen.isSmallScreen ? 14 : 16,
                                         color: .clear,
                                         borderColor: .customRed,
                                         textColor: .customRed,
                                         accessoryView: nil,
                                         tapped: { deleteStack() })
                    .centeredHorizontally()
                    .withDefaultPadding(padding: .horizontal)
                    .padding(.top, 36)
            }
            .edgesIgnoringSafeArea(.bottom)
            .frame(maxWidth: UIScreen.main.bounds.width)
            .withDefaultPadding(padding: .top)
            .withBackgroundColor()
            .navigationbarHidden()
            .withSnackBar(text: "Link Copied", shouldShow: $showSnackBar)
        }
        .withPopup {
            Popup<EmptyView>(isShowing: showPopup,
                             title: popup.map { $0.0 } ?? "",
                             subtitle: popup.map { $0.1 } ?? "",
                             firstAction: .init(name: "Okay", tapped: { popup = nil }),
                             secondAction: nil)
        }
    }

    func nameChanged() {
        var updatedStack = stack
        updatedStack.name = name
        store.send(.main(action: .updateStack(stack: updatedStack)))
    }

    func captionChanged() {
        var updatedStack = stack
        updatedStack.caption = caption
        store.send(.main(action: .updateStack(stack: updatedStack)))
    }
}

extension StackDetailView {
    enum NavigationDestination {
        case inventoryItem(InventoryItem), itemSelector(Stack), empty
    }

    struct Destination: View {
        @EnvironmentObject var store: AppStore
        @Binding var navigationDestination: Navigation<NavigationDestination>
        @Binding var inventoryItems: [InventoryItem]

        var body: some View {
            switch navigationDestination.destination {
            case let .inventoryItem(inventoryItem):
                InventoryItemDetailView(inventoryItem: inventoryItem) { navigationDestination.hide() }
            case let .itemSelector(stack):
                SelectStackItemsView(stack: stack,
                                     inventoryItems: inventoryItems,
                                     requestInfo: store.state.requestInfo,
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
