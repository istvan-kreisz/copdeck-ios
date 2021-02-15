//
//  StockView.swift
//  InfluTrader
//
//  Created by István Kreisz on 2/15/21.
//

import SwiftUI

struct StockView: View {
    @Binding var stock: Stock?

    var body: some View {
        VStack {
            Text(stock?.id ?? "nah")
            Button(action: {
                self.stock = nil
            }) {
                    Text("Click me")
            }
            .frame(width: 30, height: 30)
        }
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
        .background(Color.green)
        .edgesIgnoringSafeArea(.all)
    }
}
