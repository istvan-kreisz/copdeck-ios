//
//  AccessoryButton.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct AccessoryButton: View {
    let title: String
    let color: Color
    let textColor: Color
    var borderColor: Color?
    var fontSize: CGFloat = 12
    var height: CGFloat = 27
    let width: CGFloat?
    var padding: CGFloat = 10
    let imageName: String
    var buttonPosition: RoundedButtonPosition = .left
    let tapped: () -> Void

    var body: some View {
        RoundedButton(text: title,
                      width: width,
                      height: height,
                      fontSize: fontSize,
                      color: .clear,
                      borderColor: borderColor ?? color.opacity(0.4),
                      textColor: textColor,
                      padding: padding,
                      accessoryView: (ZStack {
                          Circle()
                              .fill(color.opacity(0.2))
                              .frame(width: 18, height: 18)
                          Image(systemName: imageName)
                              .font(.bold(size: 7))
                              .foregroundColor(color)
                      }.frame(width: 18, height: 18),
                      buttonPosition, 6, .none)) {
                tapped()
        }
    }
}
