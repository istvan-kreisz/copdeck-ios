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

    static let collapsedElementTopPadding: CGFloat = -11

    @Binding var inventoryItemParent: InventoryItem
    @State var inventoryItem: InventoryItem
    @Binding var updateSignal: Int

    @Binding var tags: [Tag]
    let purchasePrice: PriceWithCurrency?
    let currency: Currency
    let style: Style
    let sortedSizes: [ItemType: [String]]
    let sizesConverted: [ItemType: [String]]
    let showCopDeckPrice: Bool
    let highlightCopDeckPrice: Bool
    let addQuantitySelector: Bool
    let didTapDelete: (() -> Void)?
    let onCopDeckPriceTooltipTapped: (() -> Void)?
    let didTapAddTag: () -> Void
    let didTapDeleteTag: (Tag) -> Void

    var textFieldStyle: TextFieldRounded.Style {
        style == .card ? .gray : .white
    }

    var dropdownStyle: DropDownMenu.Style {
        style == .card ? .gray : .white
    }

    let listingPricesItem = [GridItem(.flexible())]

    init(inventoryItem: Binding<InventoryItem>?,
         tags: Binding<[Tag]>,
         updateSignal: Binding<Int>,
         purchasePrice: PriceWithCurrency?,
         currency: Currency,
         style: Style = .card,
         sortedSizes: [ItemType: [String]],
         sizesConverted: [ItemType: [String]],
         showCopDeckPrice: Bool,
         highlightCopDeckPrice: Bool,
         addQuantitySelector: Bool,
         didTapDelete: (() -> Void)? = nil,
         onCopDeckPriceTooltipTapped: (() -> Void)? = nil,
         didTapAddTag: @escaping (() -> Void),
         didTapDeleteTag: @escaping (Tag) -> Void) {
        self._inventoryItemParent = inventoryItem ?? Binding.constant(InventoryItem.init(fromItem: .sample))
        self._inventoryItem = State(initialValue: inventoryItem?.wrappedValue ?? InventoryItem.init(fromItem: .sample))
        self._tags = tags
        self._updateSignal = updateSignal
        self.purchasePrice = purchasePrice
        self.currency = currency
        self.style = style
        self.sortedSizes = sortedSizes
        self.sizesConverted = sizesConverted
        self.showCopDeckPrice = showCopDeckPrice
        self.highlightCopDeckPrice = highlightCopDeckPrice
        self.addQuantitySelector = addQuantitySelector
        self.didTapDelete = didTapDelete
        self.onCopDeckPriceTooltipTapped = onCopDeckPriceTooltipTapped
        self.didTapAddTag = didTapAddTag
        self.didTapDeleteTag = didTapDeleteTag
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

            PriceRow(textFieldTitle: "sell price",
                     dateTitle: "sold on",
                     textFieldStyle: textFieldStyle,
                     dropdownStyle: dropdownStyle,
                     defaultCurrency: currency)
            { inventoryItem.soldPrice?.price }
            setPrice: { inventoryItem.soldPrice = .init(storeId: nil, price: $0) }
            getDate: { inventoryItem.soldDate }
            setDate: { inventoryItem.soldDate = $0 }
                .collapsible(buttonTitle: "add sell details",
                             style: style,
                             contentHeight: Styles.inputFieldHeight,
                             topPaddingWhenCollapsed: Self.collapsedElementTopPadding,
                             isShowing: inventoryItem.soldPrice != nil || inventoryItem.soldDate != nil,
                             onHide: {
                                 inventoryItem.soldPrice = nil
                                 inventoryItem.soldDate = nil
                             }, onShow: {
                                 inventoryItem.soldPrice = .init(storeId: nil, price: .init(price: 0, currencyCode: currency.code))
                                 inventoryItem.soldDate = Date.serverDate
                             })

            QuantityAndConditionSelector(dropdownStyle: dropdownStyle,
                                         getCondition: { inventoryItem.condition },
                                         setCondition: { inventoryItem.condition = $0 },
                                         getQuantity: addQuantitySelector ? { inventoryItem.count } : nil,
                                         setQuantity: addQuantitySelector ? { inventoryItem.count = $0 } : nil)
                .collapsible(buttonTitle: addQuantitySelector ? "add quantity & condition" : "add condition",
                             style: style,
                             contentHeight: DropDownMenu.height,
                             topPaddingWhenCollapsed: Self.collapsedElementTopPadding,
                             onHide: {
                                 inventoryItem.count = 1
                                 inventoryItem.condition = .new
                             })

            TagSelector(style: style, tags: $tags, selectedTags: $inventoryItem.tags, didTapAddTag: didTapAddTag, didTapDeleteTag: didTapDeleteTag)
                .collapsible(buttonTitle: "add tags",
                             style: style,
                             contentHeight: TagView.height + TagSelector.padding * 2,
                             topPaddingWhenCollapsed: Self.collapsedElementTopPadding,
                             isShowing: !inventoryItem.tags.isEmpty,
                             onHide: { inventoryItem.tags.removeAll() })

            if !showCopDeckPrice && !AppStore.default.state.stacks.isEmpty {
                StacksSelector(style: style, selectedStacks: $inventoryItem._addToStacks)
                    .collapsible(buttonTitle: "add to stack(s)",
                                 style: style,
                                 contentHeight: StackSelectorView.height + StacksSelector.padding * 2,
                                 topPaddingWhenCollapsed: Self.collapsedElementTopPadding,
                                 onHide: { inventoryItem._addToStacks.removeAll() })
            }

            SizeSelector(style: style,
                         sortedSizes: inventoryItem.sortedSizes,
                         sizesConverted: sizesConverted,
                         itemType: $inventoryItem.itemType,
                         selectedSize: $inventoryItem.convertedSize)
        }
        .buttonStyle(PlainButtonStyle())
        .if(style == .card) {
            $0
                .padding(10)
                .background(Color.customWhite)
                .cornerRadius(12)
                .withDefaultShadow()
        }
        .onChange(of: updateSignal) { newValue in
            inventoryItemParent = inventoryItem
        }
    }
}
