//
//  DropDownMenu.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/22/21.
//

import Foundation
import SwiftUI

#warning("fix tappable area")

struct DropDownMenu: View {
    enum Style {
        case gray, white
    }

    var title: String
    @Binding var selectedItem: String
    var options: [String]
    var style: Style = .gray

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.regular(size: 12))
                .foregroundColor(style == .white ? .customText1 : .customText2)
                .padding(.leading, 5)

            GeometryReader { geo in
                Picker(selection: $selectedItem,
                       label: Text(selectedItem).leftAligned()) {
                        ForEach(options, id: \.self) {
                            Text($0)
                        }
                }
                .padding(.leading, 10)
                .pickerStyle(MenuPickerStyle())
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
        }
    }
}

struct DropDownMenu_Previews: PreviewProvider {
    static var previews: some View {
        DropDownMenu(title: "test", selectedItem: .constant("yo"), options: ["yo", "hey", "sup"])
    }
}
