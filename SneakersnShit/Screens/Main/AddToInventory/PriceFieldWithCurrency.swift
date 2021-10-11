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
    let textFieldStyle: TextFieldRounded.Style
    let dropDownStyle: DropDownMenu.Style
    @Binding var price: String
    @Binding var currency: String
    var onEdited: ((Bool) -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 11) {
            TextFieldRounded(title: title,
                             placeHolder: "0",
                             style: textFieldStyle,
                             keyboardType: .numberPad,
                             text: $price,
                             onEdited: onEdited)
            DropDownMenu(title: "currency",
                         selectedItem: $currency,
                         options: ALLSELECTABLECURRENCYSYMBOLS.map(\.rawValue),
                         style: dropDownStyle)
                .frame(width: 75)
        }
    }
}
