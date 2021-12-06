//
//  PriceRow.swift
//  CopDeck
//
//  Created by István Kreisz on 12/6/21.
//

import SwiftUI

struct PriceRow: View {
    let textFieldTitle: String
    var titleColor: Color? = nil
    var dateTitle: String? = nil
    let textFieldStyle: TextFieldRounded.Style
    let dropdownStyle: DropDownMenu.Style
    let defaultCurrency: Currency

    let getPrice: () -> PriceWithCurrency?
    let setPrice: (PriceWithCurrency) -> Void
    var getDate: (() -> Double?)?
    var setDate: ((Double) -> Void)?

    var onTooltipTapped: (() -> Void)? = nil

    func updatePrice(newPrice: String? = nil, newCurrencySymbol: String? = nil) -> PriceWithCurrency {
        let price = (newPrice.map { Double($0) } ?? getPrice()?.price) ?? 0
        let currencyCode = (newCurrencySymbol.map { Currency.currency(withSymbol: $0)?.code } ?? getPrice()?.currencyCode) ?? defaultCurrency.code
        return PriceWithCurrency(price: price, currencyCode: currencyCode)
    }

    @ViewBuilder func datePicker(title: String, date: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.regular(size: 12))
                .foregroundColor(.customText1)
                .padding(.leading, 5)

            DatePicker(selection: date, displayedComponents: .date) {
                EmptyView().frame(width: 0, alignment: .leading)
            }
            .labelsHidden()
            .accentColor(.customText2)
            .layoutPriority(2)
            .centeredVertically()
            .frame(height: Styles.inputFieldHeight)
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            let soldPrice = Binding<String>(get: { (getPrice()?.price).asString(defaultValue: "") },
                                            set: { setPrice(updatePrice(newPrice: $0)) })
            let soldCurrency =
                Binding<String>(get: { getPrice()?.currencySymbol.rawValue ?? self.defaultCurrency.symbol.rawValue },
                                set: { setPrice(updatePrice(newCurrencySymbol: $0)) })

            PriceFieldWithCurrency(title: textFieldTitle,
                                   textFieldStyle: textFieldStyle,
                                   dropDownStyle: dropdownStyle,
                                   price: soldPrice,
                                   currency: soldCurrency,
                                   onTooltipTapped: onTooltipTapped)
            if let dateTitle = dateTitle, let getDate = getDate, let setDate = setDate {
                let soldDate = Binding<Date>(get: { getDate().serverDate ?? Date() },
                                             set: { setDate($0.timeIntervalSince1970 * 1000) })
                datePicker(title: dateTitle, date: soldDate)
            }
        }
    }
}
