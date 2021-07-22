//
//  NewItemCard.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/21/21.
//

import SwiftUI

struct NewItemCard: View {
    @Binding var inventoryItem: InventoryItem
    @State var status = "NONE"
    @State var soldOn = "NONE"

    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 11) {
                HStack(alignment: .top, spacing: 11) {
                    let condition = Binding<String>(get: { inventoryItem.condition.rawValue },
                                                    set: { inventoryItem.condition = .init(rawValue: $0) ?? .new })
                    TextFieldRounded(title: "purchase price",
                                     placeHolder: (inventoryItem.item?.retailPrice).asString,
                                     style: .gray,
                                     text: $inventoryItem.name)
                    DropDownMenu(title: "size",
                                 selectedItem: $inventoryItem.size,
                                 options: inventoryItem.item?.sortedSizes ?? [])
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
                            ForEach(ALLSTORES) { store in
                                let text =
                                    Binding<String>(get: {
                                                        (inventoryItem.listingPrices
                                                            .first(where: { $0.storeId == store.id })?.price).asString
                                                    },
                                                    set: { new in
                                                        if let index = inventoryItem.listingPrices.firstIndex(where: { $0.storeId == store.id }) {
                                                            inventoryItem.listingPrices.remove(at: index)
                                                        }
                                                        inventoryItem.listingPrices.append(.init(storeId: store.id, price: Double(new) ?? 0))
                                                    })
                                TextFieldRounded(title: store.id.rawValue.lowercased(),
                                                 placeHolder: "$0",
                                                 style: .gray,
                                                 text: text)
                            }
                        }
                    }
                    .padding(.top, 5)
                } else if status == "SOLD" {
                    let text =
                        Binding<String>(get: { (inventoryItem.soldPrice?.price).asString },
                                        set: { new in
                                            inventoryItem.soldPrice = .init(storeId: inventoryItem.soldPrice?.storeId,
                                                                            price: Double(new))

                                        })
                    VStack(alignment: .leading, spacing: 11) {
                        HStack {
                            TextFieldRounded(title: "selling price (optional)",
                                             placeHolder: "$0",
                                             style: .gray,
                                             text: text)
                            Spacer()
                        }
                        ToggleButton(title: "sold on (optional)",
                                     selection: $soldOn,
                                     options: ["NONE"] + ALLSTORES.map { $0.id.rawValue.uppercased() })
                    }
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
        NewItemCard(inventoryItem: .constant(.init(from: .sample)))
    }
}
