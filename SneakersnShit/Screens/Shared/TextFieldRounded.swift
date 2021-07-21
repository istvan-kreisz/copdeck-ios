//
//  TextFieldRounded.swift
//  CopDeck
//
//  Created by István Kreisz on 7/14/21.
//

import SwiftUI

struct TextFieldRounded: View {
    var title: String?
    var placeHolder: String
    var backgroundColor = Color.white
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title ?? "")
                .font(.regular(size: 12))
                .foregroundColor(.customText1)
                .padding(.leading, 5)

            TextField(placeHolder, text: $text)
                .frame(height: Styles.inputFieldHeight)
                .padding(.horizontal, 17)
                .background(backgroundColor)
                .cornerRadius(Styles.cornerRadius)
                .withDefaultShadow()
                .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}
