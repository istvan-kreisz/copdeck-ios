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
    let purchasePrice: PriceWithCurrency?
    let currency: Currency
    let style: Style
    let sizes: [String]
    let showCopDeckPrice: Bool
    let highlightCopDeckPrice: Bool
    let addQuantitySelector: Bool
    let didTapDelete: (() -> Void)?
    let onCopDeckPriceTooltipTapped: (() -> Void)?

    var sizesConverted: [String] {
        sizes.asSizes(of: inventoryItem)
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
         purchasePrice: PriceWithCurrency?,
         currency: Currency,
         style: Style = .card,
         sizes: [String],
         showCopDeckPrice: Bool,
         highlightCopDeckPrice: Bool,
         addQuantitySelector: Bool,
         didTapDelete: (() -> Void)? = nil,
         onCopDeckPriceTooltipTapped: (() -> Void)? = nil) {
        self._inventoryItem = inventoryItem ?? Binding.constant(InventoryItem.init(fromItem: .sample))
        self.purchasePrice = purchasePrice
        self.currency = currency
        self.style = style
        self.sizes = sizes
        self.showCopDeckPrice = showCopDeckPrice
        self.highlightCopDeckPrice = highlightCopDeckPrice
        self.addQuantitySelector = addQuantitySelector
        self.didTapDelete = didTapDelete
        self.onCopDeckPriceTooltipTapped = onCopDeckPriceTooltipTapped
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
                    Text("remove")
                        .font(.semiBold(size: 14))
                        .foregroundColor(Color.customRed)
                }
//                DeleteButton(style: .line) {
//                    didTapDelete?()
//                }
                .rightAligned()
                .padding(.bottom, -12)
            }

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
                                       currency: soldCurrency)  { isActive in
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
            let size = Binding<String>(get: { inventoryItem.convertedSize },
                                       set: { inventoryItem.convertedSize = $0 })
            DropDownMenu(title: "size",
                         selectedItem: size,
                         options: sizesConverted,
                         style: dropdownStyle)
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
