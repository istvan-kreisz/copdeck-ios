//
//  InputField.swift
//  CopDeck
//
//  Created by István Kreisz on 4/4/20.
//  Copyright © 2020 István Kreisz. All rights reserved.
//

import SwiftUI

struct TextFieldUnderlined: View {
    @Binding var text: String
    let placeHolder: String
    let color: Color
    let dismissKeyboardOnReturn: Bool
    let icon: Image?
    let keyboardType: UIKeyboardType
    let isSecureField: Bool
    var textAlignment: TextAlignment = .leading
    var trailingPadding: CGFloat = 15
    var addLeadingPadding: Bool = true
    var height: CGFloat? = 45
    let onFinishedEditing: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 5) {
                icon?
                    .renderingMode(.template)
                    .frame(width: 18)
                    .foregroundColor(.customAccent1)
                Group {
                    if isSecureField {
                        SecureField(placeHolder, text: $text, onCommit: onFinishedEditing)
                            .multilineTextAlignment(textAlignment)
                    } else {
                        TextField(placeHolder, text: $text, onEditingChanged: { isActive in
                            if !isActive {
                                onFinishedEditing()
                            }
                        })
                            .multilineTextAlignment(textAlignment)
                    }
                }
            }
            .keyboardType(keyboardType)
            .background(Color.clear)
            .foregroundColor(color)
            .font(.regular(size: 20))
            .padding(.leading, addLeadingPadding ? nil : 0)
            Rectangle()
                .fill(Color.customAccent2)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
        .frame(height: height)
        .padding(.trailing, trailingPadding)
    }
}
