//
//  PackageCellView.swift
//  CopDeck
//
//  Created by István Kreisz on 10/25/21.
//

import SwiftUI
import Purchases

struct PackageCellView: View {
    let color: Color
    let package: Purchases.Package
    let onSelection: (Purchases.Package) -> Void

    private static let width: CGFloat = 110
    private static let height: CGFloat = 65

    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .center, spacing: 0) {
                ZStack {
                    Rectangle()
                        .fill(color)
                    Text("1\n\(package.duration)".uppercased())
                        .multilineTextAlignment(.center)
                        .font(.bold(size: 18))
                        .foregroundColor(.customWhite)
                }
                .frame(width: Self.width, height: Self.height)
                ZStack {
                    Rectangle()
                        .fill(color.opacity(0.5))
                    VStack {
                        Text(package.localizedPriceString.uppercased())
                            .font(.bold(size: 18))
                            .foregroundColor(.customText1)
                        if let monthlyPriceString = package.priceString(for: .monthly) {
                            Text("\(monthlyPriceString) / mo")
                                .font(.bold(size: 14))
                                .foregroundColor(.customText1)
                        }
                    }
                }
                .frame(width: Self.width, height: Self.height)
            }
            .cornerRadius(Styles.cornerRadius)
        }
        .onTapGesture {
            onSelection(package)
        }
    }
}
