//
//  PackageCellView.swift
//  CopDeck
//
//  Created by István Kreisz on 10/25/21.
//

import SwiftUI
import Purchases

struct PackageCellView: View {
    let package: Purchases.Package
    let onSelection: (Purchases.Package) -> Void
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(package.product.localizedTitle)
                        .font(.title3)
                        .bold()
                    
                    Spacer()
                }
                HStack {
                    Text(package.terms(for: package))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding([.top, .bottom], 8.0)
            
            Spacer()
            
            Text(package.localizedPriceString)
                .font(.title3)
                .bold()
        }.onTapGesture {
            onSelection(package)
        }
    }
}
