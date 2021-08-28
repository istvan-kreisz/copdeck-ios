//
//  StackDetail.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/28/21.
//

import SwiftUI
import Combine

struct StackDetail: View {
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
            VStack {
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
        VStack(alignment: .center, spacing: 8) {
            NavigationBar(title: stack.name, isBackButtonVisible: true, style: .dark) { showView = false }
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
                .withDefaultPadding(padding: .horizontal)
                .padding(.top, 5)
            }
            .padding(10)
            .background(Color.customWhite)
            .cornerRadius(12)
            .withDefaultShadow()

            TextFieldRounded(title: "stack name",
                             placeHolder: "name",
                             style: .white,
                             text: $name) { newName in
                    // save name
            }

            TextFieldRounded(title: "caption (optional)",
                             placeHolder: "caption",
                             style: .white,
                             text: $caption) { newCaption in
                    // save name
            }

            let isPublished = Binding<Bool>(get: { stack.isPublished == true },
                                            set: { isPublished in log(isPublished) })

            toggleView(title: "Publish on Feed",
                       buttonTitle: "How does this work?",
                       isOn: isPublished) {}

            toggleView(title: "Make Public",
                       buttonTitle: "How does this work?",
                       isOn: isPublished) {}
            ZStack {
                Text(linkURL)
                    .foregroundColor(.customText2)
                    .frame(width: nil, height: Styles.inputFieldHeight)
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

            VerticalListView(bottomPadding: 130, addHorizontalPadding: false, toolbar: EmptyView()) {
                ForEach(allStackItems) { (inventoryItem: InventoryItem) in
                    InventoryListItem(inventoryItem: inventoryItem,
                                      bestPrice: bestPrices[inventoryItem.id],
                                      selectedInventoryItemId: $selectedInventoryItemId,
                                      isSelected: false,
                                      isEditing: .constant(false),
                                      requestInfo: requestInfo) {}
                }
                .padding(.vertical, 6)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .frame(maxWidth: UIScreen.main.bounds.width)
        .withDefaultPadding(padding: .top)
        .withDefaultPadding(padding: .horizontal)
        .withBackgroundColor()

//        .withFloatingButton(button: RoundedButton<EmptyView>(text: "Save Changes",
//                                                             width: 200,
//                                                             height: 60,
//                                                             color: .customBlack,
//                                                             accessoryView: nil) {
//                saveChanges(selectedStackItems)
//                showView = false
//            }
//            .centeredHorizontally()
//            .padding(.top, 20))
        .navigationbarHidden()
        .withSnackBar(text: "Link Copied", shouldShow: $showSnackBar)
    }

    func copyLinkTapped() {
        UIPasteboard.general.string = linkURL
        showSnackBar = true
    }
}
