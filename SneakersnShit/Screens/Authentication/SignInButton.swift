//
//  SignInButton.swift
//  CopDeck
//
//  Created by István Kreisz on 4/12/20.
//  Copyright © 2020 István Kreisz. All rights reserved.
//

import SwiftUI

struct SignInButton: View {
    let imageName: String
    let text: String
    let imageColor: Color?
    let backgroundColor: Color
    let action: () -> Void

    init(imageName: String, text: String, imageColor: Color?, backgroundColor: Color, action: @escaping () -> Void, initBlock: () -> Void) {
        self.imageName = imageName
        self.text = text
        self.imageColor = imageColor
        self.backgroundColor = backgroundColor
        self.action = action
        initBlock()
    }

    var body: some View {
        Button(action: action) {
            Image(imageName)
                .renderingMode(imageColor == nil ? .original : .template)
                .resizable()
                .foregroundColor(imageColor)
                .scaledToFit()
                .frame(width: 24, height: 24)
                .centeredVertically()
                .frame(width: 48, height: 48)
                .background(backgroundColor)
                .cornerRadius(25)
        }
    }
}

