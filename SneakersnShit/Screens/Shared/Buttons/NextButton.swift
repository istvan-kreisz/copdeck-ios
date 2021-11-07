//
//  NextButton.swift
//  CopDeck
//
//  Created by István Kreisz on 7/15/21.
//

import SwiftUI

struct NextButton: View {
    let text: String
    let size: CGSize
    let maxSize: CGSize?
    let fontSize: CGFloat
    let color: Color
    let tapped: () -> Void

    @ViewBuilder func iconView() -> some View {
        ZStack {
            Circle()
                .fill(Color.customWhite.opacity(0.2))
                .frame(width: 30, height: 30, alignment: .center)
            Image(systemName: "chevron.right")
                .font(.bold(size: 14))
                .foregroundColor(.customWhite)
        }
    }

    init(text: String,
         size: CGSize,
         maxSize: CGSize? = nil,
         fontSize: CGFloat = 16,
         color: Color = .customBlack,
         tapped: @escaping () -> Void) {
        self.text = text
        self.size = size
        self.maxSize = maxSize
        self.fontSize = fontSize
        self.color = color
        self.tapped = tapped
    }

    var body: some View {
        RoundedButton(text: text,
                      width: size.width,
                      height: size.height,
                      maxSize: maxSize,
                      fontSize: fontSize,
                      color: color,
                      borderColor: color,
                      accessoryView: (iconView(), .right, nil, .middle),
                      tapped: tapped)
    }
}
