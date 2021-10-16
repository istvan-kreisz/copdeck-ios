//
//  NewItemCard.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/21/21.
//

import SwiftUI

#warning("currrencyyyyyyy")

struct NewItemCard: View {
    enum Style {
        case card, noBackground
    }

    @State var didTapPurchasePrice = false
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
         didTapDelete: (() -> Void)? = nil) {
        self._inventoryItem = inventoryItem ?? Binding.constant(InventoryItem.init(fromItem: .sample))
        self.purchasePrice = purchasePrice
        self.currency = currency
        self.style = style
        self.sizes = sizes
        self.showCopDeckPrice = showCopDeckPrice
        self.highlightCopDeckPrice = highlightCopDeckPrice
        self.addQuantitySelector = addQuantitySelector
        self.didTapDelete = didTapDelete
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
        let soldStatus = Binding<String>(get: { (inventoryItem.status ?? InventoryItem.SoldStatus.None).rawValue.uppercased() },
                                         set: { new in
                                             let newValue = .init(rawValue: new.lowercased().capitalized) ?? InventoryItem.SoldStatus.None
                                             inventoryItem.status = newValue
                                             if newValue == .Sold, inventoryItem.soldDate == nil {
                                                 inventoryItem.soldDate = Date.serverDate
                                             }
                                         })

        VStack(alignment: .leading, spacing: 11) {
            if didTapDelete != nil {
                DeleteButton(style: .line) {
                    didTapDelete?()
                }
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
                let condition = Binding<String>(get: { inventoryItem.condition.rawValue },
                                                set: { inventoryItem.condition = .init(rawValue: $0) ?? .new })
                let size = Binding<String>(get: { inventoryItem.convertedSize },
                                           set: { inventoryItem.convertedSize = $0 })
                let quantity = Binding<String>(get: { "\(inventoryItem.count)" }, set: { inventoryItem.count = Int($0) ?? 1 })

                DropDownMenu(title: "size",
                             selectedItem: size,
                             options: sizesConverted,
                             style: dropdownStyle)
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
                                       currency: currency)
            }

            ToggleButton(title: "status",
                         selection: soldStatus,
                         options: ["NONE", "LISTED", "SOLD"],
                         style: toggleButtonStyle)
            if inventoryItem.status == .Listed {
                VStack(alignment: .leading, spacing: 4) {
                    Text("listing prices (optional)")
                        .font(.semiBold(size: 12))
                        .foregroundColor(.customBlack)
                        .padding(.leading, 5)

                    LazyVGrid(columns: listingPricesItem, alignment: .leading, spacing: 10) {
                        ForEach(ALLSTORESWITHOTHER) { (store: GenericStore) in
                            let price =
                                Binding<String>(get: { (inventoryItem.listingPrices.first(where: { $0.storeId == store.id })?.price.price).asString() },
                                                set: { inventoryItem.setListingPrice(price: $0, defaultCurrency: self.currency, storeId: store.id) })

                            let currency =
                                Binding<String>(get: {
                                                    inventoryItem.listingPrices.first(where: { $0.storeId == store.id })?.price.currencySymbol.rawValue ?? self
                                                        .currency.symbol
                                                        .rawValue
                                                },
                                                set: { inventoryItem.setListingCurrency(currency: $0, storeId: store.id) })

                            PriceFieldWithCurrency(title: "\(store.id) price",
                                                   textFieldStyle: textFieldStyle,
                                                   dropDownStyle: dropdownStyle,
                                                   price: price,
                                                   currency: currency)
                        }
                    }
                }
                .padding(.top, 5)
            } else if inventoryItem.status == .Sold {
                let soldPrice =
                    Binding<String>(get: { (inventoryItem.soldPrice?.price?.price).asString() },
                                    set: { inventoryItem.setSoldPrice(price: $0, defaultCurrency: self.currency) })
                let soldCurrency =
                    Binding<String>(get: { inventoryItem.soldPrice?.price?.currencySymbol.rawValue ?? self.currency.symbol.rawValue },
                                    set: { inventoryItem.setSoldPriceCurrency(currency: $0) })
                let soldStore =
                    Binding<String>(get: { inventoryItem.soldPrice?.storeId?.uppercased() ?? "OTHER" },
                                    set: { inventoryItem.setSoldStore(storeId: $0.lowercased()) })

                VStack(alignment: .leading, spacing: 11) {
                    HStack(alignment: .top, spacing: 11) {
                        let soldDate = Binding<Date>(get: { inventoryItem.soldDate.serverDate ?? Date() },
                                                     set: { new in inventoryItem.soldDate = new.timeIntervalSince1970 * 1000 })

                        PriceFieldWithCurrency(title: "selling price (optional)",
                                               textFieldStyle: textFieldStyle,
                                               dropDownStyle: dropdownStyle,
                                               price: soldPrice,
                                               currency: soldCurrency)

                        datePicker(title: "sold date", date: soldDate)
                    }

                    ToggleButton(title: "sold on (optional)",
                                 selection: soldStore,
                                 options: ALLSTORESWITHOTHER.map { (store: GenericStore) in store.id.uppercased() },
                                 style: toggleButtonStyle)
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
