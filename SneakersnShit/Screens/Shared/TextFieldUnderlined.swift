//
//  InputField.swift
//  ToDo
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
                    } else {
                        TextField(placeHolder, text: $text, onCommit: onFinishedEditing)
                    }
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .keyboardType(keyboardType)
            .background(Color.clear)
            .foregroundColor(color)
            .font(.regular(size: 20))
            .padding(.leading)
            Rectangle()
                .fill(Color.customAccent2)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
        .frame(height: 45)
        .padding(.trailing, 15)
    }
}

struct InputField_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldUnderlined(text: .constant("email"),
                            placeHolder: "Email",
                            color: .clear,
                            dismissKeyboardOnReturn: false,
                            icon: Image("profile"),
                            keyboardType: .emailAddress,
                            isSecureField: false,
                            onFinishedEditing: {})
    }
}
