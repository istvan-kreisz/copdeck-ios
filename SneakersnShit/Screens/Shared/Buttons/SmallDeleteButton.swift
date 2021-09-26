//
//  SmallDeleteButton.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/26/21.
//

import SwiftUI

struct SmallDeleteButton: View {
    enum Style {
        case line, fill
    }

    let style: Style
    let didTap: () -> Void

    var body: some View {
        Button(action: didTap) {
            ZStack {
                Color.clear.frame(width: 22, height: 22)
                if style == .line {
                    Circle()
                        .stroke(Color.customRed, lineWidth: 2)
                        .frame(width: 18, height: 18)
                } else {
                    Circle()
                        .fill(Color.customRed)
                        .frame(width: 18, height: 18)
                }
                Image(systemName: "xmark")
                    .font(.bold(size: 11))
                    .foregroundColor(style == .line ? Color.customRed : Color.customWhite)
            }.frame(width: 18, height: 18)
        }
    }
}
