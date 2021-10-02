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

    @Binding var inventoryItem: InventoryItem
    let purchasePrice: PriceWithCurrency?
    let currency: Currency
    let style: Style
    let sizes: [String]
    let showCopDeckPrice: Bool
    let didTapDelete: (() -> Void)?

    var textFieldStyle: TextFieldRounded.Style {
        style == .card ? .gray : .white
    }

    var dropdownStyle: DropDownMenu.Style {
        style == .card ? .gray : .white
    }

    var toggleButtonStyle: ToggleButton.Style {
        style == .card ? .gray : .white
    }
    
    let listingPricesItem = [
        GridItem(.adaptive(minimum: 70, maximum: 70)),
    ]

    init(inventoryItem: Binding<InventoryItem>?,
         purchasePrice: PriceWithCurrency?,
         currency: Currency,
         style: Style = .card,
         sizes: [String],
         showCopDeckPrice: Bool,
         didTapDelete: (() -> Void)? = nil) {
        self._inventoryItem = inventoryItem ?? Binding.constant(InventoryItem.init(fromItem: .sample))
        self.purchasePrice = purchasePrice
        self.currency = currency
        self.style = style
        self.sizes = sizes
        self.showCopDeckPrice = showCopDeckPrice
        self.didTapDelete = didTapDelete
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            if didTapDelete != nil {
                DeleteButton(style: .line) {
                    didTapDelete?()
                }
                .rightAligned()
                .padding(.bottom, -12)
            }

            HStack(alignment: .top, spacing: 11) {
                let condition = Binding<String>(get: { inventoryItem.condition.rawValue },
                                                set: { inventoryItem.condition = .init(rawValue: $0) ?? .new })
                let purchasePrice = Binding<String>(get: { (inventoryItem.purchasePrice?.price).asString() },
                                                    set: { new in
                                                        inventoryItem.purchasePrice = PriceWithCurrency(price: Double(new) ?? 0, currencyCode: currency.code)
                                                    })
                TextFieldRounded(title: "purchase price",
                                 placeHolder: (self.purchasePrice?.price).asString(),
                                 style: textFieldStyle,
                                 keyboardType: .numberPad,
                                 text: purchasePrice) { isActive in
                    if isActive, style == .card {
                        if !didTapPurchasePrice {
                            didTapPurchasePrice = true
                            inventoryItem.purchasePrice = nil
                        }
                    }
                }
                DropDownMenu(title: "size",
                             selectedItem: $inventoryItem.size,
                             options: sizes,
                             style: dropdownStyle)
                DropDownMenu(title: "condition",
                             selectedItem: condition,
                             options: InventoryItem.Condition.allCases.map { $0.rawValue },
                             style: dropdownStyle)
            }
            if showCopDeckPrice {
                let price = Binding<String>(get: {
                                                if let price = inventoryItem.copdeckPrice?.price.price, price > 0 {
                                                    return price.rounded(toPlaces: 0)
                                                } else {
                                                    return ""
                                                }
                                            },
                                            set: { new in
                                                inventoryItem.copdeckPrice = ListingPrice(storeId: "copdeck",
                                                                                          price: .init(price: Double(new) ?? 0,
                                                                                                       currencyCode: inventoryItem.copdeckPrice?.price
                                                                                                           .currencyCode ?? self.currency.code))
                                            })
                let currency =
                    Binding<String>(get: { inventoryItem.copdeckPrice?.price.currencySymbol.rawValue ?? self.currency.symbol.rawValue },
                                    set: { currency in
                                        if let currency = Currency.currrency(withSymbol: currency) {
                                            let price = inventoryItem.copdeckPrice?.price.price ?? 0
                                            inventoryItem.copdeckPrice = ListingPrice(storeId: "copdeck",
                                                                                      price: .init(price: price, currencyCode: currency.code))
                                        }
                                    })

                HStack(spacing: 11) {
                    TextFieldRounded(title: "copdeck price (optional)",
                                     placeHolder: "0",
                                     style: textFieldStyle,
                                     keyboardType: .numberPad,
                                     text: price)
                    DropDownMenu(title: "currency",
                                 selectedItem: currency,
                                 options: ALLSELECTABLECURRENCYSYMBOLS.map(\.rawValue),
                                 style: .white)
                        .frame(width: 75)
                }
            }

            let soldStatus = Binding<String>(get: { (inventoryItem.status ?? InventoryItem.SoldStatus.None).rawValue.uppercased() },
                                             set: { inventoryItem.status = .init(rawValue: $0.lowercased().capitalized) ?? InventoryItem.SoldStatus.None })
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
                            let text =
                                Binding<String>(get: {
                                                    (inventoryItem.listingPrices
                                                        .first(where: { $0.storeId == store.id })?.price.price).asString()
                                                },
                                                set: { new in
                                                    if let index = inventoryItem.listingPrices.firstIndex(where: { $0.storeId == store.id }) {
                                                        inventoryItem
                                                            .listingPrices[index] = ListingPrice(storeId: store.id,
                                                                                                 price: .init(price: Double(new) ?? 0,
                                                                                                              currencyCode: self.currency.code))
                                                    } else {
                                                        inventoryItem.listingPrices
                                                            .append(.init(storeId: store.id,
                                                                          price: .init(price: Double(new) ?? 0, currencyCode: currency.code)))
                                                    }
                                                })
                            TextFieldRounded(title: store.id.lowercased(),
                                             placeHolder: "\(currency.symbol.rawValue)0",
                                             style: textFieldStyle,
                                             keyboardType: .numberPad,
                                             text: text,
                                             width: 70)
                        }
                    }
                }
                .padding(.top, 5)
            } else if inventoryItem.status == .Sold {
                let text =
                    Binding<String>(get: { (inventoryItem.soldPrice?.price?.price).asString() },
                                    set: {
                                        inventoryItem
                                            .soldPrice = .init(storeId: inventoryItem.soldPrice?.storeId,
                                                               price: Double($0).asPriceWithCurrency(currency: currency))
                                    })
                let soldOn =
                    Binding<String>(get: { inventoryItem.soldPrice?.storeId?.uppercased() ?? "OTHER" },
                                    set: { inventoryItem.soldPrice = .init(storeId: $0.lowercased(), price: inventoryItem.soldPrice?.price) })

                VStack(alignment: .leading, spacing: 11) {
                    HStack {
                        TextFieldRounded(title: "selling price (optional)",
                                         placeHolder: "\(currency.symbol.rawValue)0",
                                         style: textFieldStyle,
                                         keyboardType: .numberPad,
                                         text: text)
                        Rectangle().fill(Color.clear).frame(height: 1)
                    }
                    ToggleButton(title: "sold on (optional)",
                                 selection: soldOn,
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

struct NewItemCard_Previews: PreviewProvider {
    static var previews: some View {
        NewItemCard(inventoryItem: .constant(InventoryItem.init(fromItem: Item.sample)),
                    purchasePrice: Item.sample.retailPrice.map { PriceWithCurrency(price: $0, currencyCode: .usd) },
                    currency: Currency(code: .usd, symbol: .usd),
                    sizes: [],
                    showCopDeckPrice: false)
    }
}
