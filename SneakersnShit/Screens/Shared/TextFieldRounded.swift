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
    var placeHolder: String
    let style: Style
    @Binding var text: String
    var width: CGFloat? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title ?? "")
                .font(.regular(size: 12))
                .foregroundColor(.customText2)
                .padding(.leading, 5)

            TextField(placeHolder, text: $text)
                .frame(width: width, height: Styles.inputFieldHeight)
                .padding(.horizontal, 17)
                .background(style == .white ? Color.white : Color.customAccent4)
                .cornerRadius(Styles.cornerRadius)
                .if(style == .white) { $0.withDefaultShadow() }
                .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}
