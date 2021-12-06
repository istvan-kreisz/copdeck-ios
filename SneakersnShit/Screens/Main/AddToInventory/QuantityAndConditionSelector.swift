//
//  QuantityAndConditionSelector.swift
//  CopDeck
//
//  Created by István Kreisz on 12/6/21.
//

import SwiftUI

struct QuantityAndConditionSelector: View {
    let dropdownStyle: DropDownMenu.Style

    let getCondition: () -> InventoryItem.Condition
    let setCondition: (InventoryItem.Condition) -> Void
    var getQuantity: (() -> Int)?
    var setQuantity: ((Int) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            let condition = Binding<String>(get: { getCondition().rawValue },
                                            set: { setCondition(.init(rawValue: $0) ?? .new) })

            if let setQuantity = setQuantity, let getQuantity = getQuantity {
                let quantity = Binding<String>(get: { "\(getQuantity())" }, set: { setQuantity(Int($0) ?? 1) })
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
    }
}
