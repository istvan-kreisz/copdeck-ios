//
//  StackDetail.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/28/21.
//

import SwiftUI
import Combine

struct StackDetail: View {
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

    @State private var showItemSelector = false
    @State private var showSnackBar = false

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
    }

    var body: some View {
        let isPublished = Binding<Bool>(get: { stack.isPublished == true },
                                        set: { isPublished in didTogglePublished(newValue: isPublished) })
        let isPublic = Binding<Bool>(get: { stack.isPublic == true },
                                     set: { isPublic in didTogglePublic(newValue: isPublic) })

        Group {
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

            VerticalListView(bottomPadding: 130, addHorizontalPadding: false, toolbar: EmptyView()) {
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
                .padding(10)
                .background(Color.customWhite)
                .cornerRadius(12)
                .withDefaultPadding(padding: .horizontal)
                .withDefaultShadow()

                TextFieldRounded(title: "stack name",
                                 placeHolder: "name",
                                 style: .white,
                                 text: $name) { newName in
                        // save name
                }
                .withDefaultPadding(padding: .horizontal)

                TextFieldRounded(title: "caption (optional)",
                                 placeHolder: "caption",
                                 style: .white,
                                 text: $caption) { newCaption in
                        // save name
                }
                .withDefaultPadding(padding: .horizontal)

                toggleView(title: "Publish on Feed",
                           buttonTitle: "How does this work?",
                           isOn: isPublished) {}
                    .withDefaultPadding(padding: .horizontal)

                toggleView(title: "Make Public",
                           buttonTitle: "How does this work?",
                           isOn: isPublic) {}
                    .withDefaultPadding(padding: .horizontal)

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

                VStack(alignment: .leading, spacing: 4) {
                    Text("sneakers")
                        .font(.regular(size: 12))
                        .foregroundColor(.customText1)
                        .padding(.leading, 5)
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
                        .padding(.top, 3)
                        .withDefaultPadding(padding: .horizontal)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .edgesIgnoringSafeArea(.bottom)
            .frame(maxWidth: UIScreen.main.bounds.width)
            .withDefaultPadding(padding: .top)
            .withBackgroundColor()
            .navigationbarHidden()
            .withSnackBar(text: "Link Copied", shouldShow: $showSnackBar)
        }
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
        if newValue {
            updatedStack.isPublic = newValue
        }
        store.send(.main(action: .updateStack(stack: updatedStack)))
    }

    func didTogglePublic(newValue: Bool) {
        var updatedStack = stack
        updatedStack.isPublic = newValue
        if !newValue {
            updatedStack.isPublished = newValue
        }
        store.send(.main(action: .updateStack(stack: updatedStack)))
    }
}
