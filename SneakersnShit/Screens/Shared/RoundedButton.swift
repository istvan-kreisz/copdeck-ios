//
//  RoundedButton.swift
//  CopDeck
//
//  Created by István Kreisz on 7/14/21.
//

import SwiftUI

struct RoundedButton: View {
    enum Position {
        case left, right, middle, none
    }

    let text: String
    let size: CGSize
    let maxSize: CGSize?
    let fontSize: CGFloat
    let color: Color
    let borderColor: Color
    let textColor: Color
    let padding: CGFloat
    let accessoryView: (AnyView, Position, CGFloat?, Position)?
    let tapped: () -> Void

    init(text: String,
         size: CGSize,
         maxSize: CGSize? = nil,
         fontSize: CGFloat = 16,
         color: Color = .customBlack,
         borderColor: Color = .clear,
         textColor: Color = .white,
         padding: CGFloat = 20,
         accessoryView: (AnyView, Position, CGFloat?, Position)?,
         tapped: @escaping () -> Void) {
        self.text = text
        self.size = size
        self.maxSize = maxSize
        self.fontSize = fontSize
        self.color = color
        self.borderColor = borderColor
        self.textColor = textColor
        self.padding = padding
        self.accessoryView = accessoryView
        self.tapped = tapped
    }

    var body: some View {
        Button(action: tapped, label: {
            HStack(alignment: .center, spacing: 5) {
                if accessoryView?.3 == .left {
                    Spacer()
                }
                if let accessoryView = accessoryView, accessoryView.1 == .left {
                    accessoryView.0
                        .layoutPriority(2)
                    if accessoryView.3 == .middle {
                        Spacer()
                    }
                }
                Text(text.uppercased())
                    .lineLimit(1)
                    .font(.bold(size: fontSize))
                    .foregroundColor(textColor)
                    .layoutPriority(2)
                if let accessoryView = accessoryView, accessoryView.1 == .right {
                    if accessoryView.3 == .middle {
                        Spacer()
                    }
                    accessoryView.0
                        .layoutPriority(2)
                }
                if accessoryView?.3 == .right {
                    Spacer()
                }
            }
            .padding(.horizontal, accessoryView?.2 ?? padding)
            .frame(width: maxSize.map { min($0.width, size.width) } ?? size.width,
                   height: maxSize.map { min($0.height, size.height) } ?? size.height)
            .if(color != .clear) {
                $0.background(Capsule().fill(color))
            }
            .if(borderColor != .clear) {
                $0.background(Capsule().stroke(borderColor, lineWidth: 2))
            }
        })
    }
}

struct RoundedButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundedButton(text: "Button",
                      size: .init(width: 300, height: 50),
                      color: .customBlack,
                      accessoryView: nil,
                      tapped: {})
    }
}
