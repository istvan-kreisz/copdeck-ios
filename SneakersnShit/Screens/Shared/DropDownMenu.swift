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
    var title: String
    @Binding var selectedItem: String
    var options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.regular(size: 12))
                .foregroundColor(.customText2)
                .padding(.leading, 5)

            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                GeometryReader { geo in
                    Picker(selection: $selectedItem,
                           label: Text(selectedItem).leftAligned()) {
                            ForEach(options, id: \.self) {
                                Text($0)
                            }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(10)
                    .padding(.trailing, 10)
                    .frame(width: geo.frame(in: .local).width)
                    .foregroundColor(.customText1)

                    Image(systemName: "chevron.down")
                        .font(.bold(size: 14))
                        .foregroundColor(.customText1)
                        .padding(.trailing, 10)
                        .centeredVertically()
                        .rightAligned()
                        .allowsHitTesting(false)
                }
                .frame(height: Styles.inputFieldHeight)
                .background(Color.customAccent4)
                .cornerRadius(Styles.cornerRadius)
                .withDefaultShadow()
            }
        }
    }
}

struct DropDownMenu_Previews: PreviewProvider {
    static var previews: some View {
        DropDownMenu(title: "test", selectedItem: .constant("yo"), options: ["yo", "hey", "sup"])
    }
}
