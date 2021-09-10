//
//  RoundedButton.swift
//  CopDeck
//
//  Created by István Kreisz on 7/14/21.
//

import SwiftUI

enum RoundedButtonPosition {
    case left, right, middle, none
}

struct RoundedButton<V: View>: View {
    let text: String
    let width: CGFloat?
    let height: CGFloat?
    let maxSize: CGSize?
    let fontSize: CGFloat
    let color: Color
    let borderColor: Color
    let textColor: Color
    let padding: CGFloat
    let accessoryView: (V, RoundedButtonPosition, CGFloat?, RoundedButtonPosition)?
    let tapped: () -> Void

    var buttonWidth: CGFloat? {
        if let width = width {
            if let maxWidth = maxSize?.width {
                return min(maxWidth, width)
            } else {
                return width
            }
        } else {
            return nil
        }
    }

    var buttonHeight: CGFloat? {
        if let height = height {
            if let maxHeight = maxSize?.height {
                return min(maxHeight, height)
            } else {
                return height
            }
        } else {
            return nil
        }
    }

    init(text: String,
         width: CGFloat?,
         height: CGFloat?,
         maxSize: CGSize? = nil,
         fontSize: CGFloat = 16,
         color: Color = .customBlack,
         borderColor: Color = .clear,
         textColor: Color = .customWhite,
         padding: CGFloat = 20,
         accessoryView: (V, RoundedButtonPosition, CGFloat?, RoundedButtonPosition)?,
         tapped: @escaping () -> Void) {
        self.text = text
        self.width = width
        self.height = height
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
            .frame(width: buttonWidth, height: buttonHeight)
            .background(Capsule().fill(color))
            .background(Capsule().stroke(borderColor, lineWidth: 2))
        })
    }
}

struct RoundedButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundedButton<EmptyView>(text: "Button",
                                 width: 300,
                                 height: 50,
                                 color: .customBlack,
                                 accessoryView: nil,
                                 tapped: {})
    }
}
