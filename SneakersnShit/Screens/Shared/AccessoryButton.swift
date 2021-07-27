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
    let width: CGFloat
    let tapped: () -> Void

    var body: some View {
        RoundedButton(text: title,
                      size: .init(width: width, height: 27),
                      fontSize: 12,
                      color: .clear,
                      borderColor: color.opacity(0.4),
                      textColor: textColor,
                      padding: 10,
                      accessoryView: (AnyView(ZStack {
                          Circle()
                              .fill(color.opacity(0.2))
                              .frame(width: 18, height: 18)
                          Image(systemName: "plus")
                              .font(.bold(size: 7))
                              .foregroundColor(color)
                      }.frame(width: 18, height: 18)),
                      .left, 10, .none)) {
                tapped()
        }
    }
}

struct AccessoryButton_Previews: PreviewProvider {
    static var previews: some View {
        AccessoryButton(title: "title", color: .customBlue, textColor: .customBlue, width: 110, tapped: {})
    }
}
