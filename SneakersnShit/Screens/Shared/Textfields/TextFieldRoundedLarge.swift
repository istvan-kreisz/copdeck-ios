//
//  TextFieldRoundedLarrge.swift
//  CopDeck
//
//  Created by István Kreisz on 10/19/21.
//

import SwiftUI

struct TextFieldRoundedLarge: View {
    enum Style {
        case white, gray
    }

    var title: String?
    var titleColor: Color? = nil
    var placeHolder: String
    let style: Style
    var keyboardType: UIKeyboardType = .default
    @Binding var text: String?
    var width: CGFloat? = nil
    var onEdited: ((Bool) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title = title {
                Text(title)
                    .font(.regular(size: 12))
                    .foregroundColor(titleColor ?? (style == .white ? .customText1 : .customText2))
                    .padding(.leading, 5)
            }

            ZStack(alignment: .topLeading) {
                TextEditor(text: Binding($text, replacingNilWith: ""))
                    .keyboardType(keyboardType)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.customText2)
                    .background(style == .white ? Color.customWhite : Color.customAccent4)
                    .padding(.horizontal, 8)
                    .frame(width: width, height: Styles.inputFieldHeightLarge)
                    .background(style == .white ? Color.customWhite : Color.customAccent4)
                    .cornerRadius(Styles.cornerRadius)
                    .if(style == .white) { $0.withDefaultShadow() }

                Text(text ?? placeHolder)
                    .padding(.leading, 10)
                    .padding(.top, 8)
                    .foregroundColor(Color.customText2.opacity(0.6))
                    .opacity(text == nil ? 1 : 0)
            }
        }
    }
}
