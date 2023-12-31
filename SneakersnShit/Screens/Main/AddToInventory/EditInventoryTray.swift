//
//  EditInventoryTray.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct EditInventoryTray: View {
    static let defaultSectionWidth: CGFloat = 90
    static let height: CGFloat = 60

    var sectionWidth: CGFloat {
        if actions.count == 1 {
            return 140
        } else {
            return min(Self.defaultSectionWidth, (UIScreen.screenWidth - Styles.horizontalMargin * 2) / CGFloat(actions.count))
        }
    }

    @Binding var actions: [ActionConfig]

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(actions) { (action: ActionConfig) in
                Button(action: {
                    action.tapped()
                }) {
                        Text(action.name.uppercased())
                            .multilineTextAlignment(.center)
                            .font(.bold(size: 14))
                            .foregroundColor(.customWhite)
                }
                .frame(width: sectionWidth, height: Self.height)
                .background(((actions.firstIndex(where: { $0.name == action.name }) ?? 0) % 2 == 0 && actions.count != 1) ? Color.customAccent5 : Color.clear)
            }
        }
        .frame(width: sectionWidth * CGFloat(actions.count), height: Self.height)
        .background(Color.customBlack)
        .cornerRadius(Self.height / 2)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
    }
}
