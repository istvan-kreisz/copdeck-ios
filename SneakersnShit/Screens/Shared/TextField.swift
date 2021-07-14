//
//  TextField.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/14/21.
//

import SwiftUI

struct CustomTextField: View {
    var title: String?
    var placeHolder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title ?? "")
                .font(.regular(size: 12))
                .foregroundColor(.customText1)
                .padding(.leading, 5)

            TextField(placeHolder, text: $text)
                .frame(height: 42)
                .padding(.horizontal, 17)
                .background(Color.white)
                .cornerRadius(12)
                .withDefaultShadow()
                .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}
