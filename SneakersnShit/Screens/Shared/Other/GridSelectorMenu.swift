//
//  GridSelectorMenu.swift
//  CopDeck
//
//  Created by István Kreisz on 11/9/21.
//

import Foundation
import SwiftUI

struct GridSelectorMenu: View {
    enum Style {
        case gray, white
    }

    @Binding var selectedItem: String
    var options: [String]
    var style: Style = .gray

    var items: [GridItem] {
        Array(repeating: GridItem(.flexible(minimum: 30)), count: 5)
    }

    var body: some View {
        LazyVGrid(columns: items, spacing: 10) {
            ForEach(options, id: \.self) { option in
                Text(option)
                    .foregroundColor(Color.customText1)
                    .frame(width: 40, height: 40)
                    .background(Color.customAccent1)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(option == selectedItem ? Color.red : Color.clear, lineWidth: 2))
                    .onTapGesture {
                        selectedItem = option
                    }
            }
        }
        .padding(.horizontal)
    }

//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text(title)
//                .font(.regular(size: 12))
//                .foregroundColor(style == .white ? .customText1 : .customText2)
//                .padding(.leading, 5)
//
//            GeometryReader { geo in
//                Menu {
//                    ForEach(options.reversed(), id: \.self) { option in
//                        Button(option) {
//                            selectedItem = option
//                        }
//                    }
//                } label: { Text(selectedItem)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding()
//                }
//                .padding(.leading, 0)
//                .pickerStyle(.menu)
//                .frame(width: geo.frame(in: .local).width)
//                .foregroundColor(.customText2)
//                .overlay(Image(systemName: "chevron.down")
//                    .font(.bold(size: 14))
//                    .foregroundColor(.customText2)
//                    .padding(.trailing, 10)
//                    .centeredVertically()
//                    .rightAligned()
//                    .allowsHitTesting(false))
//                .frame(height: Styles.inputFieldHeight)
//                .background(style == .gray ? Color.customAccent4 : Color.customWhite)
//                .cornerRadius(Styles.cornerRadius)
//            }
//            .frame(height: Styles.inputFieldHeight)
//        }
//        .withDefaultShadow(color: style == .white ? .customAccent3 : .clear)
//    }
}
