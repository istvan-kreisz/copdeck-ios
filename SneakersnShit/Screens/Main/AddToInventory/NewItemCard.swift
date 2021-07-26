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
    let purchasePrice: Double?
    let style: Style

    var textFieldStyle: TextFieldRounded.Style {
        style == .card ? .gray : .white
    }

    var dropdownStyle: DropDownMenu.Style {
        style == .card ? .gray : .white
    }

    var toggleButtonStyle: ToggleButton.Style {
        style == .card ? .gray : .white
    }

    init(inventoryItem: Binding<InventoryItem>?, purchasePrice: Double?, style: Style = .card) {
        self._inventoryItem = inventoryItem ?? Binding.constant(InventoryItem.init(fromItem: .sample))
        self.purchasePrice = purchasePrice
        self.style = style
//        if inventoryItem?.wrappedValue.soldPrice != nil {
//            self._status = State(initialValue: inventoryItem?.wrappedValue.status)
//        } else if inventoryItem?.wrappedValue.listingPrices.isEmpty == false {
//            self._status = State(initialValue: "LISTED")
//        } else {
//            self._status = State(initialValue: "NONE")
//        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(alignment: .top, spacing: 11) {
                let condition = Binding<String>(get: { inventoryItem.condition.rawValue },
                                                set: { inventoryItem.condition = .init(rawValue: $0) ?? .new })
                let purchasePrice = Binding<String>(get: { inventoryItem.purchasePrice.asString },
                                                    set: { new in inventoryItem.purchasePrice = Double(new) })
                TextFieldRounded(title: "purchase price",
                                 placeHolder: self.purchasePrice.asString,
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
                                                        .first(where: { $0.storeId == store.id })?.price).asString
                                                },
                                                set: { new in
                                                    if let index = inventoryItem.listingPrices.firstIndex(where: { $0.storeId == store.id }) {
                                                        inventoryItem.listingPrices[index] = InventoryItem.ListingPrice(storeId: store.id, price: Int(new) ?? 0)
                                                    } else {
                                                        inventoryItem.listingPrices.append(.init(storeId: store.id, price: Int(new) ?? 0))
                                                    }
                                                })
                            TextFieldRounded(title: store.id.lowercased(),
                                             placeHolder: "$0",
                                             style: textFieldStyle,
                                             keyboardType: .numberPad,
                                             text: text)
                        }
                    }
                }
                .padding(.top, 5)
            } else if inventoryItem.status == .sold {
                let text =
                    Binding<String>(get: { (inventoryItem.soldPrice?.price).asString },
                                    set: { inventoryItem.soldPrice = .init(storeId: inventoryItem.soldPrice?.storeId, price: Double($0)) })
                let soldOn =
                    Binding<String>(get: { inventoryItem.soldPrice?.storeId?.uppercased() ?? "OTHER" },
                                    set: { inventoryItem.soldPrice = .init(storeId: $0.lowercased(), price: inventoryItem.soldPrice?.price) })

                VStack(alignment: .leading, spacing: 11) {
                    HStack {
                        TextFieldRounded(title: "selling price (optional)",
                                         placeHolder: "$0",
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
                .background(Color.white)
                .cornerRadius(12)
                .withDefaultShadow()
        }
    }
}

struct NewItemCard_Previews: PreviewProvider {
    static var previews: some View {
        NewItemCard(inventoryItem: .constant(InventoryItem.init(fromItem: Item.sample)), purchasePrice: Item.sample.retailPrice)
    }
}
