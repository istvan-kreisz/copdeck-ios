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
    let purchasePrice: PriceWithCurrency?
    let currency: Currency
    let style: Style
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

    init(inventoryItem: Binding<InventoryItem>?,
         purchasePrice: PriceWithCurrency?,
         currency: Currency,
         style: Style = .card,
         didTapDelete: (() -> Void)? = nil) {
        self._inventoryItem = inventoryItem ?? Binding.constant(InventoryItem.init(fromItem: .sample))
        self.purchasePrice = purchasePrice
        self.currency = currency
        self.style = style
        self.didTapDelete = didTapDelete
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            if didTapDelete != nil {
                Button(action: { didTapDelete?() }, label: {
                    ZStack {
                        Color.clear.frame(width: 22, height: 22)
                        Circle()
                            .stroke(Color.customRed, lineWidth: 2)
                            .frame(width: 18, height: 18)
                        Image(systemName: "xmark")
                            .font(.bold(size: 11))
                            .foregroundColor(Color.customRed)
                    }.frame(width: 18, height: 18)
                })
                    .rightAligned()
                    .padding(.bottom, -12)
            }

            HStack(alignment: .top, spacing: 11) {
                let condition = Binding<String>(get: { inventoryItem.condition.rawValue },
                                                set: { inventoryItem.condition = .init(rawValue: $0) ?? .new })
                let purchasePrice = Binding<String>(get: { (inventoryItem.purchasePrice?.price).asString },
                                                    set: { new in
                                                        inventoryItem.purchasePrice = PriceWithCurrency(price: Double(new) ?? 0, currencyCode: currency.code)
                                                    })
                TextFieldRounded(title: "purchase price",
                                 placeHolder: (self.purchasePrice?.price).asString,
                                 style: textFieldStyle,
                                 keyboardType: .numberPad,
                                 text: purchasePrice)
                DropDownMenu(title: "size",
                             selectedItem: $inventoryItem.size,
                             options: ALLSHOESIZES,
                             style: dropdownStyle)
                DropDownMenu(title: "condition",
                             selectedItem: condition,
                             options: InventoryItem.Condition.allCases.map { $0.rawValue },
                             style: dropdownStyle)
            }
            let soldStatus = Binding<String>(get: { (inventoryItem.status ?? InventoryItem.SoldStatus.none).rawValue.uppercased() },
                                             set: { inventoryItem.status = .init(rawValue: $0.lowercased()) ?? InventoryItem.SoldStatus.none })
            ToggleButton(title: "status",
                         selection: soldStatus,
                         options: ["NONE", "LISTED", "SOLD"],
                         style: toggleButtonStyle)
            if inventoryItem.status == .listed {
                VStack(alignment: .leading, spacing: 4) {
                    Text("listing prices (optional)")
                        .font(.semiBold(size: 12))
                        .foregroundColor(.customBlack)
                        .padding(.leading, 5)

                    HStack(alignment: .top, spacing: 11) {
                        ForEach(ALLSTORESWITHOTHER) { store in
                            let text =
                                Binding<String>(get: {
                                                    (inventoryItem.listingPrices
                                                        .first(where: { $0.storeId == store.id })?.price.price).asString
                                                },
                                                set: { new in
                                                    if let index = inventoryItem.listingPrices.firstIndex(where: { $0.storeId == store.id }) {
                                                        inventoryItem.listingPrices[index] = InventoryItem
                                                            .ListingPrice(storeId: store.id, price: .init(price: Double(new) ?? 0, currencyCode: currency.code))
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
                                             text: text)
                        }
                    }
                }
                .padding(.top, 5)
            } else if inventoryItem.status == .sold {
                let text =
                    Binding<String>(get: { (inventoryItem.soldPrice?.price?.price).asString },
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
                                 options: ALLSTORESWITHOTHER.map { $0.id.uppercased() },
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
                    currency: Currency(code: .usd, symbol: .usd))
    }
}
