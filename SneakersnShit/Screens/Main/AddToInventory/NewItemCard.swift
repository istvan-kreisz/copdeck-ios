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
                .rightAligned()
                .padding(.trailing, 3)
                .padding(.bottom, -4)
            }

            PriceRow(textFieldTitle: "purchase price",
                     dateTitle: "purchased on",
                     textFieldStyle: textFieldStyle,
                     dropdownStyle: dropdownStyle,
                     defaultCurrency: currency)
            { inventoryItem.purchasePrice }
            setPrice: { inventoryItem.purchasePrice = $0 }
            getDate: { inventoryItem.purchasedDate }
            setDate: { inventoryItem.purchasedDate = $0 }

            PriceRow(textFieldTitle: "selling price",
                     dateTitle: "sold on",
                     textFieldStyle: textFieldStyle,
                     dropdownStyle: dropdownStyle,
                     defaultCurrency: currency)
            { inventoryItem.soldPrice?.price }
            setPrice: { inventoryItem.soldPrice = .init(storeId: nil, price: $0) }
            getDate: { inventoryItem.soldDate }
            setDate: { inventoryItem.soldDate = $0 }
                .collapsible(buttonTitle: "add selling details",
                             style: style,
                             contentHeight: Styles.inputFieldHeight,
                             showIf: { inventoryItem.soldPrice != nil || inventoryItem.soldDate != nil },
                             onHide: {
                                 inventoryItem.soldPrice = nil
                                 inventoryItem.soldDate = nil
                             })

            if showCopDeckPrice {
                PriceRow(textFieldTitle: "copdeck price",
                         titleColor: highlightCopDeckPrice ? .customRed : nil,
                         textFieldStyle: textFieldStyle,
                         dropdownStyle: dropdownStyle,
                         defaultCurrency: currency)
                { inventoryItem.copdeckPrice?.price }
                setPrice: { inventoryItem.copdeckPrice = .init(storeId: "copdeck", price: $0) }
                onTooltipTapped: { onCopDeckPriceTooltipTapped?() }
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
            .collapsible(isActive: addQuantitySelector,
                         buttonTitle: "add quantity & condition",
                         style: style,
                         contentHeight: DropDownMenu.height,
                         onHide: {
                             inventoryItem.count = 1
                             inventoryItem.condition = .new
                         })

            let tagPadding: CGFloat = 3
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
                        Color.clear.frame(width: 2)
                    }
                    .padding(.vertical, tagPadding)
                }
            }
            .collapsible(buttonTitle: "add tags",
                         style: style,
                         contentHeight: TagView.height + tagPadding * 2,
                         showIf: { !inventoryItem.tags.isEmpty },
                         onHide: { inventoryItem.tags.removeAll() })

            let stacksPadding: CGFloat = 3
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
                        .padding(.vertical, stacksPadding)
                    }
                }
                .collapsible(buttonTitle: "add to stack(s)",
                             style: style,
                             contentHeight: StackSelectorView.height + stacksPadding * 2,
                             onHide: { inventoryItem._addToStacks.removeAll() })
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
