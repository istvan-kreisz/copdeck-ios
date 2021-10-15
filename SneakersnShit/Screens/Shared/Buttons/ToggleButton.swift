//
//  ToggleButton.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/22/21.
//

import SwiftUI

struct ToggleButton: View {
    enum Style {
        case white, gray
    }

    var title: String
    @Binding var selection: String
    var options: [String]
    var style: Style = .gray
    
    static var width: CGFloat {
        UIScreen.isSmallScreen ? 60 : 68
    }
    
    static var height: CGFloat {
        UIScreen.isSmallScreen ? 26 : 28
    }
    
    let rows = [
        GridItem(.adaptive(minimum: Self.width, maximum: Self.width))
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.regular(size: 12))
                .foregroundColor(style == .white ? .customText1 : .customText2)
                .padding(.leading, 5)

            
            LazyVGrid(columns: rows, alignment: .leading, spacing: 5) {
                ForEach(options, id: \.self) { (option: String) in
                    Text(option)
                        .font(.bold(size: UIScreen.isSmallScreen ? 10 : 11))
                        .frame(width: Self.width, height: Self.height)
                        .foregroundColor(option == selection ? Color.customWhite : Color.customText1)
                        .background(Capsule().fill(option == selection ? Color.customBlue : Color.clear))
                        .background(Capsule().stroke(option == selection ? Color.clear : Color.customBlue, lineWidth: 2))
                        .onTapGesture {
                            selection = option
                        }
                }
            }
        }
    }
}

struct ToggleButton_Previews: PreviewProvider {
    static var previews: some View {
        ToggleButton(title: "test", selection: .constant("yo"), options: ["yo", "hey", "sup"])
    }
}
