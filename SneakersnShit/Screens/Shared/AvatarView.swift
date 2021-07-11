//
//  AvatarView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 2/14/21.
//

import SwiftUI

struct AvatarView: View {
    private let size: CGFloat = 80
    private let imageURL: String
    private let text: String
    
    init(imageURL: String, text: String = "") {
        self.imageURL = imageURL
        self.text = text
    }

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .frame(width: size, height: size)
                    .foregroundColor(Color.randomColor())
                ImageView(withURL: imageURL, size: size, aspectRatio: 1)
                    .cornerRadius(size / 2)
            }
            if !text.isEmpty {
                Text(text)                
            }
        }
        .padding()
    }
}
