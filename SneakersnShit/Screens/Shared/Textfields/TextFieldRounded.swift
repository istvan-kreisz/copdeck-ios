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

    var title: String?
    var titleColor: Color? = nil
    var placeHolder: String
    let style: Style
    var keyboardType: UIKeyboardType = .default
    @Binding var text: String
    var width: CGFloat? = nil
    var addClearButton = false
    var onEdited: ((Bool) -> Void)?
    var onTooltipTapped: (() -> Void)? = nil
    
    private func textField(trailingPadding: CGFloat = 0) -> some View {
        TextField(placeHolder, text: $text, onEditingChanged: { isActive in
            onEdited?(isActive)
        })
            .keyboardType(keyboardType)
            .foregroundColor(.customText2)
            .padding(.horizontal, 8)
            .padding(.trailing, trailingPadding)
            .frame(width: width, height: Styles.inputFieldHeight)
            .background(style == .white ? Color.customWhite : Color.customAccent4)
            .cornerRadius(Styles.cornerRadius)
            .if(style == .white) { $0.withDefaultShadow() }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title = title {
                HStack(alignment: .center, spacing: 3) {
                    Text(title)
                        .font(.regular(size: 12))
                        .foregroundColor(titleColor ?? (style == .white ? .customText1 : .customText2))
                        .padding(.leading, 5)
                    if let onTooltipTapped = onTooltipTapped {
                        Button(action: onTooltipTapped) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.regular(size: 13))
                                .foregroundColor(titleColor ?? (style == .white ? .customText1 : .customText2))
                        }
                    }
                }
            }
            if addClearButton {
                textField(trailingPadding: 20)
                    .withClearButton(text: $text, textFieldWidth: width)
            } else {
                textField()
            }
            
        }
    }
}
