//
//  NewItemCard.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/21/21.
//

import SwiftUI

struct NewItemCard: View {
    @Binding var inventoryItem: InventoryItem
    let item: Item
    @State var status = "NONE"
    @State var soldOn = "NONE"

    init(inventoryItem: Binding<InventoryItem>?, item: Item) {
        self._inventoryItem = inventoryItem ?? Binding.constant(InventoryItem.init(fromItem: .sample))
        self.item = item
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(alignment: .top, spacing: 11) {
                let condition = Binding<String>(get: { inventoryItem.condition.rawValue },
                                                set: { inventoryItem.condition = .init(rawValue: $0) ?? .new })
                let purchasePrice = Binding<String>(get: { inventoryItem.purchasePrice.asString },
                                                    set: { new in inventoryItem.purchasePrice = Double(new) })
                TextFieldRounded(title: "purchase price",
                                 placeHolder: item.retailPrice.asString,
                                 style: .gray,
                                 keyboardType: .numberPad,
                                 text: purchasePrice)
                DropDownMenu(title: "size",
                             selectedItem: $inventoryItem.size,
                             options: item.sortedSizes)
                DropDownMenu(title: "condition",
                             selectedItem: condition,
                             options: InventoryItem.Condition.allCases.map { $0.rawValue })
            }
            ToggleButton(title: "status", selection: $status, options: ["NONE", "LISTED", "SOLD"])
            if status == "LISTED" {
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
                                             style: .gray,
                                             keyboardType: .numberPad,
                                             text: text)
                        }
                    }
                }
                .padding(.top, 5)
            } else if status == "SOLD" {
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
                                         style: .gray,
                                         keyboardType: .numberPad,
                                         text: text)
                        Rectangle().fill(Color.clear).frame(height: 1)
                    }
                    ToggleButton(title: "sold on (optional)",
                                 selection: soldOn,
                                 options: ALLSTORESWITHOTHER.map { $0.id.uppercased() })
                }
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(12)
        .withDefaultShadow()
    }
}

struct NewItemCard_Previews: PreviewProvider {
    static var previews: some View {
        NewItemCard(inventoryItem: .constant(InventoryItem.init(fromItem: Item.sample)), item: Item.sample)
    }
}
