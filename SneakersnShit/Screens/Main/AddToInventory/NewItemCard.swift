//
//  NewItemCard.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/21/21.
//

import SwiftUI

struct NewItemCard: View {
    enum Style {
        case card, noBackground
    }

    @State var didTapPurchasePrice = false
    @State var didTapSellingPrice = false
    @State private var date = Date()

    @Binding var inventoryItem: InventoryItem
    @Binding var tags: [Tag]
    let purchasePrice: PriceWithCurrency?
    let currency: Currency
    let style: Style
    let sizes: [ItemType: [String]]
    let showCopDeckPrice: Bool
    let highlightCopDeckPrice: Bool
    let addQuantitySelector: Bool
    let didTapDelete: (() -> Void)?
    let onCopDeckPriceTooltipTapped: (() -> Void)?
    let didTapAddTag: () -> Void
    
    @State var showPurchaseRow = false

    var sizesConverted: [ItemType: [String]] {
        var sizesUpdated = self.sizes
        sizesUpdated[.shoe] = sizesUpdated[.shoe]?.asSizes(of: inventoryItem)
        return sizesUpdated
    }

    var textFieldStyle: TextFieldRounded.Style {
        style == .card ? .gray : .white
    }

    var dropdownStyle: DropDownMenu.Style {
        style == .card ? .gray : .white
    }

    var toggleButtonStyle: ToggleButton.Style {
        style == .card ? .gray : .white
    }

    let listingPricesItem = [GridItem(.flexible())]

    init(inventoryItem: Binding<InventoryItem>?,
         tags: Binding<[Tag]>,
         purchasePrice: PriceWithCurrency?,
         currency: Currency,
         style: Style = .card,
         sizes: [ItemType: [String]],
         showCopDeckPrice: Bool,
         highlightCopDeckPrice: Bool,
         addQuantitySelector: Bool,
         didTapDelete: (() -> Void)? = nil,
         onCopDeckPriceTooltipTapped: (() -> Void)? = nil,
         didTapAddTag: @escaping (() -> Void)) {
        self._inventoryItem = inventoryItem ?? Binding.constant(InventoryItem.init(fromItem: .sample))
        self._tags = tags
        self.purchasePrice = purchasePrice
        self.currency = currency
        self.style = style
        self.sizes = sizes
        self.showCopDeckPrice = showCopDeckPrice
        self.highlightCopDeckPrice = highlightCopDeckPrice
        self.addQuantitySelector = addQuantitySelector
        self.didTapDelete = didTapDelete
        self.onCopDeckPriceTooltipTapped = onCopDeckPriceTooltipTapped
        self.didTapAddTag = didTapAddTag
    }

    @ViewBuilder func datePicker(title: String, date: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.regular(size: 12))
                .foregroundColor(.customText1)
                .padding(.leading, 5)

            VStack {
                Spacer()
                DatePicker(selection: date, displayedComponents: .date) {
                    EmptyView().frame(width: 0, alignment: .leading)
                }
                .labelsHidden()
                .accentColor(.customText2)
                .layoutPriority(2)
                Spacer()
            }
            .frame(height: Styles.inputFieldHeight)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            if didTapDelete != nil {
                Button {
                    didTapDelete?()
                } label: {
                    Text("delete")
                        .font(.semiBold(size: 14))
                        .foregroundColor(Color.customRed)
                }
//                DeleteButton(style: .line) {
//                    didTapDelete?()
//                }
                .rightAligned()
                .padding(.trailing, 3)
                .padding(.bottom, -4)
            }

            let showPurchaseRow_ = Binding<Bool>(get: { inventoryItem.purchasePrice != nil || inventoryItem.purchasedDate != nil || showPurchaseRow },
                                                 set: { isShowing in
                showPurchaseRow = isShowing
                if !isShowing {
                    inventoryItem.purchasePrice = nil
                    inventoryItem.purchasedDate = nil
                }
            })

            HStack(alignment: .top, spacing: 11) {
                let purchasePrice = Binding<String>(get: { (inventoryItem.purchasePrice?.price).asString() },
                                                    set: { inventoryItem.setPurchasePrice(price: $0, defaultCurrency: currency) })
                let purchaseCurrency =
                    Binding<String>(get: { inventoryItem.purchasePrice?.currencySymbol.rawValue ?? currency.symbol.rawValue },
                                    set: { inventoryItem.setPurchaseCurrency(currency: $0) })
                let purchasedDate = Binding<Date>(get: { inventoryItem.purchasedDate.serverDate ?? Date() },
                                                  set: { new in inventoryItem.purchasedDate = new.timeIntervalSince1970 * 1000 })

                PriceFieldWithCurrency(title: "purchase price",
                                       textFieldStyle: textFieldStyle,
                                       dropDownStyle: dropdownStyle,
                                       price: purchasePrice,
                                       currency: purchaseCurrency) { isActive in
                    if isActive, style == .card {
                        if !didTapPurchasePrice {
                            didTapPurchasePrice = true
                            inventoryItem.purchasePrice = nil
                        }
                    }
                }
                datePicker(title: "purchased date", date: purchasedDate)
            }
            .collapsible(title: nil, buttonTitle: "add purchase details", titleColor: nil, style: style, deleteButtonBottomPadding: 12, isShowing: showPurchaseRow_, onTooltipTapped: nil)
            
            
            HStack(alignment: .top, spacing: 11) {
                let soldPrice =
                    Binding<String>(get: { (inventoryItem.soldPrice?.price?.price).asString() },
                                    set: { inventoryItem.setSoldPrice(price: $0, defaultCurrency: self.currency) })
                let soldCurrency =
                    Binding<String>(get: { inventoryItem.soldPrice?.price?.currencySymbol.rawValue ?? self.currency.symbol.rawValue },
                                    set: { inventoryItem.setSoldPriceCurrency(currency: $0) })
                let soldDate = Binding<Date>(get: { inventoryItem.soldDate.serverDate ?? Date() },
                                             set: { new in inventoryItem.soldDate = new.timeIntervalSince1970 * 1000 })

                PriceFieldWithCurrency(title: "selling price (optional)",
                                       textFieldStyle: textFieldStyle,
                                       dropDownStyle: dropdownStyle,
                                       price: soldPrice,
                                       currency: soldCurrency) { isActive in
                    if isActive, style == .card {
                        if !didTapSellingPrice {
                            didTapSellingPrice = true
                            inventoryItem.soldPrice = nil
                        }
                    }
                }
                datePicker(title: "sold date", date: soldDate)
            }
            if showCopDeckPrice {
                let price = Binding<String>(get: { (inventoryItem.copdeckPrice?.price.price).map { $0.rounded(toPlaces: 0) } ?? "" },
                                            set: { inventoryItem.setCopDeckPrice(price: $0, defaultCurrency: self.currency) })
                let currency =
                    Binding<String>(get: { inventoryItem.copdeckPrice?.price.currencySymbol.rawValue ?? self.currency.symbol.rawValue },
                                    set: { inventoryItem.setCopDeckCurrency(currency: $0) })

                PriceFieldWithCurrency(title: "copdeck price (optional)",
                                       titleColor: highlightCopDeckPrice ? .customRed : nil,
                                       textFieldStyle: textFieldStyle,
                                       dropDownStyle: dropdownStyle,
                                       price: price,
                                       currency: currency,
                                       onTooltipTapped: onCopDeckPriceTooltipTapped)
            }

            HStack(alignment: .top, spacing: 11) {
                let condition = Binding<String>(get: { inventoryItem.condition.rawValue },
                                                set: { inventoryItem.condition = .init(rawValue: $0) ?? .new })
                let quantity = Binding<String>(get: { "\(inventoryItem.count)" }, set: { inventoryItem.count = Int($0) ?? 1 })

                if addQuantitySelector {
                    DropDownMenu(title: "quantity",
                                 selectedItem: quantity,
                                 options: Array(0 ... 10).map { "\($0)" },
                                 style: dropdownStyle)
                }
                DropDownMenu(title: "condition",
                             selectedItem: condition,
                             options: InventoryItem.Condition.allCases.map { $0.rawValue },
                             style: dropdownStyle)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("tags")
                    .font(.regular(size: 12))
                    .foregroundColor(style == .card ? .customText2 : .customText1)
                    .padding(.leading, 5)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Color.clear.frame(width: 2)
                        ForEach(tags) { tag in
                            let isSelected = Binding<Bool>(get: {
                                                               inventoryItem.tags.contains { $0.id == tag.id }
                                                           },
                                                           set: { newValue in
                                                               if newValue {
                                                                   if !inventoryItem.tags.contains(where: { $0.id == tag.id }) {
                                                                       inventoryItem.tags.append(tag)
                                                                   }
                                                               } else {
                                                                   inventoryItem.tags = inventoryItem.tags.filter { $0.id != tag.id }
                                                               }
                                                           })
                            TagView(title: tag.name, color: tag.uiColor, isSelected: isSelected)
                        }
                        AccessoryButton(title: "new tag",
                                        shouldCapitalizeTitle: false,
                                        color: .customAccent1,
                                        textColor: .customText1,
                                        height: TagView.height,
                                        width: 80,
                                        accessoryViewSize: 16,
                                        imageName: "plus",
                                        buttonPosition: .right,
                                        isContentLocked: false,
                                        tapped: didTapAddTag)
                    }
                    .padding(.vertical, 3)
                }
            }

            if !showCopDeckPrice && !AppStore.default.state.stacks.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("add to stack(s)")
                        .font(.regular(size: 12))
                        .foregroundColor(style == .card ? .customText2 : .customText1)
                        .padding(.leading, 5)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Color.clear.frame(width: 2)
                            ForEach(AppStore.default.state.stacks) { (stack: Stack) in
                                let isSelected = Binding<Bool>(get: { inventoryItem._addToStacks.map(\.id).contains(stack.id) },
                                                               set: { newValue in
                                                                   if newValue {
                                                                       if !inventoryItem._addToStacks.map(\.id).contains(stack.id) {
                                                                           inventoryItem._addToStacks.append(stack)
                                                                       }
                                                                   } else {
                                                                       inventoryItem._addToStacks = inventoryItem._addToStacks.filter { $0.id != stack.id }
                                                                   }
                                                               })
                                StackSelectorView(title: stack.name, color: .customPurple, isSelected: isSelected)
                            }
                        }
                        .padding(.vertical, 3)
                    }
                }
            }

            Group {
                let itemType = Binding<String>(get: { inventoryItem.itemType.rawValue },
                                               set: { newValue in
                                                   let newType = ItemType(rawValue: newValue.lowercased()) ?? .shoe
                                                   inventoryItem.itemType = newType
                                                   inventoryItem.size = inventoryItem.sortedSizes[newType]?.first ?? ""
                                               })
                ToggleButton(title: "size",
                             selection: itemType,
                             options: ItemType.allCases.map(\.rawValue),
                             style: toggleButtonStyle)

                if let sizesArray = sizesConverted[inventoryItem.itemType] {
                    let size = Binding<String>(get: { inventoryItem.convertedSize },
                                               set: { inventoryItem.convertedSize = $0 })

                    GridSelectorMenu(selectedItem: size, options: sizesArray, style: style)
                }
            }
        }
        .if(style == .card) {
            $0
                .padding(10)
                .background(Color.customWhite)
                .cornerRadius(12)
                .withDefaultShadow()
        }
    }
}
