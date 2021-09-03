//
//  StackDetailView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/28/21.
//

import SwiftUI
import Combine

struct StackDetailView: View {
    private static let popupTitles = ["Publish on Feed", "Make Public"]
    private static let popupDescriptions = ["some text blah blah blah", "some text blah blah blah"]

    @EnvironmentObject var store: AppStore

    @Binding var stack: Stack
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
    @State var isPublished: Bool
    @State var isPublic: Bool

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

    init(stack: Binding<Stack>,
         inventoryItems: Binding<[InventoryItem]>,
         bestPrices: Binding<[String: PriceWithCurrency]>,
         showView: Binding<Bool>,
         filters: Binding<Filters>,
         linkURL: String,
         requestInfo: [ScraperRequestInfo],
         saveChanges: @escaping ([StackItem]) -> Void) {
        self._stack = stack
        self._inventoryItems = inventoryItems
        self._bestPrices = bestPrices
        self._showView = showView
        self._filters = filters
        self.linkURL = linkURL
        self.requestInfo = requestInfo
        self.saveChanges = saveChanges
        self._name = State<String>(initialValue: stack.wrappedValue.name)
        self._caption = State<String>(initialValue: stack.wrappedValue.caption ?? "")
        self._isPublished = State<Bool>(initialValue: stack.wrappedValue.isPublished ?? false)
        self._isPublic = State<Bool>(initialValue: stack.wrappedValue.isPublic ?? false)
    }

    var body: some View {
        let isPublished = Binding<Bool>(get: { self.isPublished }, set: { didTogglePublished(newValue: $0) })
        let isPublic = Binding<Bool>(get: { self.isPublic }, set: { didTogglePublic(newValue: $0) })
        let showPopup = Binding<Bool>(get: { popupIndex != nil }, set: { show in popupIndex = show ? popupIndex : nil })
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

                toggleView(title: "Publish on Feed",
                           buttonTitle: "How does this work?",
                           isOn: isPublished) {
                        popupIndex = 0
                }
                .withDefaultPadding(padding: .horizontal)
                .buttonStyle(PlainButtonStyle())

                toggleView(title: "Make Public",
                           buttonTitle: "How does this work?",
                           isOn: isPublic) {
                        popupIndex = 1
                }
                .withDefaultPadding(padding: .horizontal)
                .buttonStyle(PlainButtonStyle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("share link")
                        .font(.regular(size: 12))
                        .foregroundColor(.customText1)
                        .padding(.leading, 5)
                    ZStack {
                        Text(linkURL)
                            .foregroundColor(.customText2)
                            .frame(height: Styles.inputFieldHeight)
                            .padding(.horizontal, 17)
                            .background(Color.customWhite)
                            .cornerRadius(Styles.cornerRadius)
                            .withDefaultShadow()
                        Button {
                            copyLinkTapped()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: Styles.cornerRadius)
                                    .fill(Color.customGreen)
                                    .frame(width: Styles.inputFieldHeight, height: Styles.inputFieldHeight)
                                Image(systemName: "link")
                                    .font(.bold(size: 15))
                                    .foregroundColor(Color.customWhite)
                            }
                        }
                        .rightAligned()
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .withDefaultPadding(padding: .horizontal)
                .padding(.vertical, 12)

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
                             title: popupIndex.map { Self.popupTitles[safe: $0] ?? "" } ?? "",
                             subtitle: popupIndex.map { Self.popupDescriptions[safe: $0] } ?? "",
                             firstAction: .init(name: "Okay", tapped: { showPopup.wrappedValue = false }),
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

    func copyLinkTapped() {
        var updatedStack = stack
        UIPasteboard.general.string = linkURL
        showSnackBar = true
        updatedStack.isSharedViaLink = true
        store.send(.main(action: .updateStack(stack: updatedStack)))
    }

    func didTogglePublished(newValue: Bool) {
        var updatedStack = stack
        updatedStack.isPublished = newValue
        isPublished = newValue
        if newValue {
            isPublic = newValue
            updatedStack.isPublic = newValue
        }
        store.send(.main(action: .updateStack(stack: updatedStack)))
    }

    func didTogglePublic(newValue: Bool) {
        var updatedStack = stack
        updatedStack.isPublic = newValue
        isPublic = newValue
        if !newValue {
            isPublished = newValue
            updatedStack.isPublished = newValue
        }
        store.send(.main(action: .updateStack(stack: updatedStack)))
    }
}
