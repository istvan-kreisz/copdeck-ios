//
//  DropDownMenu.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/22/21.
//

import Foundation
import SwiftUI

struct DropDownMenu: View {
    enum Style {
        case gray, white
    }

    var title: String
    @Binding var selectedItem: String
    var options: [String]
    var style: Style = .gray
    
    var leadingPadding: CGFloat {
        if #available(iOS 15.0, *) {
            return 1
        } else {
            return 10
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.regular(size: 12))
                .foregroundColor(style == .white ? .customText1 : .customText2)
                .padding(.leading, 5)
            


            GeometryReader { geo in
                Menu {
                    ForEach(options.reversed(), id: \.self) { option in
                        Button(option) {
                            selectedItem = option
                        }
                    }
                } label: { Text(selectedItem)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .padding(.leading, 0)
                .pickerStyle(.menu)
                .frame(width: geo.frame(in: .local).width)
                .foregroundColor(.customText2)
                .overlay(Image(systemName: "chevron.down")
                    .font(.bold(size: 14))
                    .foregroundColor(.customText2)
                    .padding(.trailing, 10)
                    .centeredVertically()
                    .rightAligned()
                    .allowsHitTesting(false))
                .frame(height: Styles.inputFieldHeight)
                .background(style == .gray ? Color.customAccent4 : Color.customWhite)
                .cornerRadius(Styles.cornerRadius)
            }
            .frame(height: Styles.inputFieldHeight)
        }
        .withDefaultShadow(color: style == .white ? .customAccent3 : .clear)
    }
}
