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
    let color: Color
    let accessoryView: AnyView?
    let tapped: () -> Void

    init(text: String, size: CGSize, color: Color = .customBlack, accessoryView: AnyView? = nil, tapped: @escaping () -> Void) {
        self.text = text
        self.size = size
        self.color = color
        self.accessoryView = accessoryView
        self.tapped = tapped
    }

    var body: some View {
        Button(action: tapped, label: {
            HStack(alignment: .center, spacing: 10) {
                Text(text.uppercased())
                    .font(.bold(size: 14))
                    .foregroundColor(.white)
                    .padding(.leading, 15)
                Spacer()
                accessoryView
                    .padding(.trailing, 15)
            }
            .frame(width: size.width, height: size.height)
            .background(Capsule().fill(color))
        })
    }
}
