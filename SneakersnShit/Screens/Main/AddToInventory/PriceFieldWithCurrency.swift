//
//  PriceFieldWithCurrency.swift
//  CopDeck
//
//  Created by István Kreisz on 10/11/21.
//

import Foundation
import SwiftUI

struct PriceFieldWithCurrency: View {
    let title: String
    var titleColor: Color? = nil
    let textFieldStyle: TextFieldRounded.Style
    let dropDownStyle: DropDownMenu.Style
    @Binding var price: String
    @Binding var currency: String
    var onEdited: ((Bool) -> Void)? = nil
    var onTooltipTapped: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 11) {
            TextFieldRounded(title: title,
                             titleColor: titleColor,
                             placeHolder: "0",
                             style: textFieldStyle,
                             keyboardType: .numberPad,
                             text: $price,
                             onEdited: onEdited,
                             onTooltipTapped: onTooltipTapped)
            DropDownMenu(title: "currency",
                         selectedItem: $currency,
                         options: ALLSELECTABLECURRENCYSYMBOLS.map(\.rawValue),
                         style: dropDownStyle)
                .frame(width: 75)
        }
    }
}
