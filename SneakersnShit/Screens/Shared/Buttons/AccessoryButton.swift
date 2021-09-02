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
    var fontSize: CGFloat = 12
    let width: CGFloat?
    let imageName: String
    var buttonPosition: RoundedButtonPosition = .left
    let tapped: () -> Void

    var body: some View {
        RoundedButton(text: title,
                      width: width,
                      height: 27,
                      fontSize: fontSize,
                      color: .clear,
                      borderColor: color.opacity(0.4),
                      textColor: textColor,
                      padding: 10,
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

struct AccessoryButton_Previews: PreviewProvider {
    static var previews: some View {
        AccessoryButton(title: "title", color: .customBlue, textColor: .customBlue, width: 110, imageName: "plus", tapped: {})
    }
}
