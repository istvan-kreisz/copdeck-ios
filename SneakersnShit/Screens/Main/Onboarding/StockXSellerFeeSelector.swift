//
//  StockXSellerFeeSelector.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/7/21.
//

import SwiftUI

struct StockXSellerFeeSelector: View {
    @State private var settings: CopDeckSettings
    @State private var stockxSellerFee: String

    init(settings: CopDeckSettings) {
        self._settings = State(initialValue: settings)
        self._stockxSellerFee = State(initialValue: "")
    }

    private func selectStockxSellerFee() {
        if let newValue = Double(stockxSellerFee) {
            if newValue <= 100, newValue >= 0, settings.feeCalculation.stockx?.sellerFee != newValue {
                settings.feeCalculation.stockx?.sellerFee = newValue
            }
        } else {
            if settings.feeCalculation.stockx?.sellerFee != 0 {
                settings.feeCalculation.stockx?.sellerFee = 0
            }
        }
    }

    var body: some View {
        SettingMenu(title: "Enter your StockX seller fee (%)",
                    buttonTitle: "Save seller fee",
                    popBackOnSelect: false,
                    buttonTapped: selectStockxSellerFee) {
                HStack {
                    Text("StockX seller fee")
                        .layoutPriority(2)
                    TextField("0%", text: $stockxSellerFee, onEditingChanged: { isActive in
                        if !isActive {
                            selectStockxSellerFee()
                        }
                    })
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
        }.onChange(of: settings) { updatedSettings in
            AppStore.default.send(.main(action: .updateSettings(settings: updatedSettings)))
        }
    }
}
