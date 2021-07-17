//
//  RoundedButton.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/14/21.
//

import SwiftUI

struct RoundedButton: View {
    let text: String
    let size: CGSize
    let maxSize: CGSize?
    let color: Color
    let accessoryView: AnyView?
    let tapped: () -> Void

    init(text: String,
         size: CGSize,
         maxSize: CGSize? = nil,
         color: Color = .customBlack,
         accessoryView: AnyView? = nil,
         tapped: @escaping () -> Void) {
        self.text = text
        self.size = size
        self.maxSize = maxSize
        self.color = color
        self.accessoryView = accessoryView
        self.tapped = tapped
    }

    var body: some View {
        Button(action: tapped, label: {
            HStack(alignment: .center, spacing: 10) {
                Text(text.uppercased())
                    .font(.bold(size: 16))
                    .foregroundColor(.white)
                    .padding(.leading, 20)
                Spacer()
                accessoryView
                    .padding(.trailing, 20)
            }
            .frame(width: maxSize.map { min($0.width, size.width) } ?? size.width,
                   height: maxSize.map { min($0.height, size.height) } ?? size.height)
            .background(Capsule().fill(color))
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
