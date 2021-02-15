//
//  SignInButton.swift
//  ToDo
//
//  Created by István Kreisz on 4/12/20.
//  Copyright © 2020 István Kreisz. All rights reserved.
//

import SwiftUI

struct SignInButton: View {
    
    let imageName: String
    let text: String
    let imageColor: Color?
    let action: () -> Void
    
    init(imageName: String, text: String, imageColor: Color?, action: @escaping () -> Void, initBlock: () -> Void) {
        self.imageName = imageName
        self.text = text
        self.imageColor = imageColor
        self.action = action
        initBlock()
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(imageName)
                    .renderingMode(imageColor == nil ? .original : .template)
                    .resizable()
                    .foregroundColor(imageColor)
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .padding(.leading)
                Text(text)
                    .font(.regular(size: 15))
                Spacer()
            }
        }
        .frame(width: 230, height: 50)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(25)
        .centeredHorizontally()
    }
}

struct SignInButton_Previews: PreviewProvider {
    static var previews: some View {
        SignInButton(imageName: "google",
                     text: "Sign in with Google",
                     imageColor: nil,
                     action: {},
                     initBlock: {})
    }
}
