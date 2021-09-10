//
//  EmptyStateButton.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/10/21.
//

import SwiftUI

struct EmptyStateButton: View {
    enum Style {
        case regular, large
    }

    let title: String
    let buttonTitle: String
    let style: Style
    let showPlusIcon: Bool
    let action: () -> Void

    var iconSize: CGFloat {
        style == .large ? 19 : 16
    }

    var body: some View {
        VStack(alignment: .center, spacing: style == .large ? 8 : 3) {
            Text(title)
                .font(.bold(size: style == .large ? 16 : 14))
                .foregroundColor(.customText2)
            Button(action: action) {
                HStack {
                    Text(buttonTitle)
                        .underline()
                        .font(.bold(size: style == .large ? 18 : 16))
                        .foregroundColor(.customBlue)
                    if showPlusIcon {
                        ZStack {
                            Circle()
                                .fill(Color.customBlue.opacity(0.2))
                                .frame(width: iconSize, height: iconSize)
                            Image(systemName: "plus")
                                .font(.bold(size: style == .large ? 8 : 7))
                                .foregroundColor(Color.customBlue)
                        }.frame(width: iconSize, height: iconSize)
                    }
                }
            }
        }
        .centeredHorizontally()
    }
}
