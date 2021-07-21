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
    let color: Color
    let tapped: () -> Void

    func iconView() -> AnyView {
        return AnyView(ZStack {
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 30, height: 30, alignment: .center)
            Image(systemName: "chevron.right")
                .font(.bold(size: 14))
                .foregroundColor(.white)
        })
    }

    init(text: String,
         size: CGSize,
         maxSize: CGSize? = nil,
         color: Color = .customBlack,
         tapped: @escaping () -> Void) {
        self.text = text
        self.size = size
        self.maxSize = maxSize
        self.color = color
        self.tapped = tapped
    }

    var body: some View {
        RoundedButton(text: text,
                      size: size,
                      maxSize: maxSize,
                      color: color,
                      accessoryView: iconView(),
                      tapped: tapped)
    }
}

struct NextButton_Previews: PreviewProvider {
    static var previews: some View {
        NextButton(text: "Next Yo", size: .init(width: 200, height: 50), color: .customBlack, tapped: {})
    }
}
