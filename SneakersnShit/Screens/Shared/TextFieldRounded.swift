//
//  TextFieldRounded.swift
//  CopDeck
//
//  Created by István Kreisz on 7/14/21.
//

import SwiftUI

struct TextFieldRounded: View {
    enum Style {
        case white, gray
    }
    enum Size {
        case regular, large
    }

    var title: String?
    var placeHolder: String
    let style: Style
    var keyboardType: UIKeyboardType = .default
    var size: Size = .regular
    @Binding var text: String
    var width: CGFloat? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            if let title = title {
                Text(title)
                    .font(.regular(size: 12))
                    .foregroundColor(style == .white ? .customText1 : .customText2)
                    .padding(.leading, 5)
            }

            if size == .regular {
                TextField(placeHolder, text: $text)
                    .keyboardType(keyboardType)
                    .foregroundColor(.customText2)
                    .frame(width: width, height: Styles.inputFieldHeight)
                    .padding(.horizontal, 17)
                    .background(style == .white ? Color.customWhite : Color.customAccent4)
                    .cornerRadius(Styles.cornerRadius)
                    .if(style == .white) { $0.withDefaultShadow() }
//                    .ignoresSafeArea(.keyboard, edges: .bottom)
            } else {
                TextEditor(text: $text)
                    .keyboardType(keyboardType)
                    .foregroundColor(.customText2)
                    .frame(width: width, height: Styles.inputFieldHeightLarge)
                    .padding(.horizontal, 17)
                    .background(style == .white ? Color.customWhite : Color.customAccent4)
                    .cornerRadius(Styles.cornerRadius)
                    .if(style == .white) { $0.withDefaultShadow() }
//                    .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
    }
}


struct TextFieldRounded_Previews: PreviewProvider {
    static var previews: some View {
        return TextFieldRounded(placeHolder: "heey", style: .gray, text: .constant(""))
    }
}
