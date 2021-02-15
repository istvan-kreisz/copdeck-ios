//
//  InputField.swift
//  ToDo
//
//  Created by István Kreisz on 4/4/20.
//  Copyright © 2020 István Kreisz. All rights reserved.
//

import SwiftUI
import Introspect

struct InputField: View {
    
    @Binding var text: String
    @Binding var isEditing: Bool
    let placeHolder: String
    let color: Color
    let dismissKeyboardOnReturn: Bool
    let accessoryView: AnyView?
    let keyboardType: UIKeyboardType
    let isSecureField: Bool
    let onFinishedEditing: () -> Void
        
    var body: some View {
        HStack {
            Group {
                if isSecureField {
                    SecureField(placeHolder, text: $text, onCommit: onFinishedEditing)
                } else {
                    TextField(placeHolder, text: $text, onCommit: onFinishedEditing)
                }
            }
                .keyboardType(keyboardType)
                .introspectTextField {
                    if self.isEditing {
                        $0.becomeFirstResponder()
                    } else if self.dismissKeyboardOnReturn {
                        $0.resignFirstResponder()
                    }
                }
                .foregroundColor(color)
                .font(.bold(size: 20))
                .padding(.leading)
            accessoryView
        }
        .frame(height: 45)
        .padding(.trailing, 15)
        .cornerRadius(15)
        .background(Color(UIColor.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(color, lineWidth: 2)
                .foregroundColor(.clear)
        )
    }
}
