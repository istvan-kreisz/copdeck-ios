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

    @State var stack: Stack
    @Binding var inventoryItems: [InventoryItem]
    @Binding var bestPrices: [String: PriceWithCurrency]
    @Binding var showView: Bool
    @Binding var filters: Filters

    let linkURL: String
    let requestInfo: [ScraperRequestInfo]
    let saveChanges: ([StackItem]) -> Void

    @State var selectedInventoryItemId: String?
    @State var name: String
    @State var caption: String

    @State var popup: (String, String)? = nil

    @State private var showItemSelector = false
    @State private var showSnackBar = false
    @State private var popupIndex: Int? = nil

    var allStackItems: [InventoryItem] {
        stack.inventoryItems(allInventoryItems: inventoryItems, filters: filters, searchText: "")
    }

    var stackValue: PriceWithCurrency? {
        if let currencyCode = bestPrices.values.first?.currencyCode {
            let sum = allStackItems
                .filter { $0.status != .Sold }
                .compactMap { bestPrices[$0.id]?.price }
                .sum()
            return PriceWithCurrency(price: sum, currencyCode: currencyCode)
        } else {
            return nil
        }
    }

    func toggleView(title: String, buttonTitle: String, isOn: Binding<Bool>, didTapButton: @escaping () -> Void) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.bold(size: 16))
                    .foregroundColor(.customText1)
                Button(action: didTapButton) {
                    Text(buttonTitle)
                        .underline()
                        .font(.bold(size: 12))
                        .foregroundColor(.customText2)
                }
            }
            Spacer()
            Toggle("", isOn: isOn)
        }
    }

    init(stack: Stack,
         inventoryItems: Binding<[InventoryItem]>,
         bestPrices: Binding<[String: PriceWithCurrency]>,
         showView: Binding<Bool>,
         filters: Binding<Filters>,
         linkURL: String,
         requestInfo: [ScraperRequestInfo],
         saveChanges: @escaping ([StackItem]) -> Void) {
        self._stack = State(initialValue: stack)
        self._inventoryItems = inventoryItems
        self._bestPrices = bestPrices
        self._showView = showView
        self._filters = filters
        self.linkURL = linkURL
        self.requestInfo = requestInfo
        self.saveChanges = saveChanges
        self._name = State<String>(initialValue: stack.name)
        self._caption = State<String>(initialValue: stack.caption ?? "")
    }

    var body: some View {
        let showPopup = Binding<Bool>(get: { popup != nil }, set: { show in popup = show ? popup : nil })
        Group {
            ForEach(inventoryItems) { (inventoryItem: InventoryItem) in
                NavigationLink(destination: InventoryItemDetailView(inventoryItem: inventoryItem) { selectedInventoryItemId = nil },
                               tag: inventoryItem.id,
                               selection: $selectedInventoryItemId) { EmptyView() }
            }

            NavigationLink(destination: SelectStackItemsView(showView: $showItemSelector,
                                                             stack: stack,
                                                             inventoryItems: inventoryItems,
                                                             requestInfo: store.state.requestInfo,
                                                             saveChanges: { updatedStackItems in
                                                                 var updatedStack = stack
                                                                 updatedStack.items = updatedStackItems
                                                                 store.send(.main(action: .updateStack(stack: updatedStack)))
                                                             }),
                           isActive: $showItemSelector) { EmptyView() }

            VerticalListView(bottomPadding: Styles.tabScreenBottomPadding, spacing: 2, addHorizontalPadding: false) {
                NavigationBar(title: stack.name, isBackButtonVisible: true, style: .dark) { showView = false }
                    .withDefaultPadding(padding: .horizontal)

                VStack {
                    Text("Stack Stats".uppercased())
                        .font(.bold(size: 12))
                        .foregroundColor(.customText2)
                        .leftAligned()
                        .withDefaultPadding(padding: .horizontal)

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
                    .withDefaultPadding(padding: .horizontal)
                    .padding(.top, 5)
                }
                .asCard()
                .withDefaultPadding(padding: .horizontal)
                .padding(.vertical, 10)

                TextFieldRounded(title: "stack name",
                                 placeHolder: "name",
                                 style: .white,
                                 text: $name) { _ in nameChanged() }
                    .withDefaultPadding(padding: .horizontal)
                    .padding(.vertical, 10)

                TextFieldRounded(title: "caption (optional)",
                                 placeHolder: "caption",
                                 style: .white,
                                 text: $caption) { _ in captionChanged() }
                    .withDefaultPadding(padding: .horizontal)
                    .padding(.vertical, 10)

                StackShareSettingsView(linkURL: linkURL,
                                       stack: stack,
                                       isPublic: stack.isPublic ?? false,
                                       isPublished: stack.isPublished ?? false) { title in
                    showSnackBar = true
                } showPopup: { title, subtitle in
                    popup = (title, subtitle)
                } updateStack: { stack in
                    store.send(.main(action: .updateStack(stack: stack)))
                }
                .withDefaultPadding(padding: .horizontal)


                ForEach(allStackItems) { (inventoryItem: InventoryItem) in
                    InventoryListItem(inventoryItem: inventoryItem,
                                      bestPrice: bestPrices[inventoryItem.id],
                                      selectedInventoryItemId: $selectedInventoryItemId,
                                      isSelected: false,
                                      isEditing: .constant(false),
                                      requestInfo: requestInfo) {}
                }
                .padding(.vertical, 6)
                .withDefaultPadding(padding: .horizontal)

                AccessoryButton(title: "Add / Delete Items",
                                color: .customBlue,
                                textColor: .customBlue,
                                width: 170,
                                imageName: "plus",
                                tapped: {
                                    showItemSelector = true
                                })
                    .leftAligned()
                    .padding(.top, 5)
                    .withDefaultPadding(padding: .horizontal)
                    .buttonStyle(PlainButtonStyle())
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
