//
//  DeleteButton.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/26/21.
//

import SwiftUI

struct DeleteButton: View {
    enum Style {
        case line, fill
    }
    enum Size {
        case small, large
    }
    static func size(_ size: Size) -> CGFloat {
        size == .small ? 18.0 : 40.0
    }
    
    var frameSize: CGFloat {
        Self.size(self.size)
    }
    
    var imageSize: CGFloat {
        self.size == .small ? 11.0 : 30.0
    }

    let style: Style
    var size: Size = .small
    var color: Color = .customRed
    let didTap: () -> Void

    var body: some View {
        Button(action: didTap) {
            ZStack {
                Color.clear.frame(width: frameSize, height: frameSize)
                if style == .line {
                    Circle()
                        .stroke(color, lineWidth: 2)
                        .frame(width: frameSize, height: frameSize)
                } else {
                    Circle()
                        .fill(color)
                        .frame(width: frameSize, height: frameSize)
                }
                Image(systemName: "xmark")
                    .font(size == .small ? .bold(size: imageSize) : .semiBold(size: imageSize))
                    .foregroundColor(style == .line ? color : Color.customWhite)
            }.frame(width: frameSize, height: frameSize)
        }
    }
}
