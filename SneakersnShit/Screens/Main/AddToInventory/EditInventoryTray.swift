//
//  EditInventoryTray.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/26/21.
//

import SwiftUI

struct EditInventoryTray: View {
    static let sectionWidth: CGFloat = 90
    static let height: CGFloat = 60

    var didTapCancel: () -> Void
    var didTapDelete: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Button(action: {
                didTapCancel()
            }) {
                Text("CANCEL")
                    .font(.bold(size: 14))
                    .foregroundColor(.white)
            }
            .frame(width: Self.sectionWidth, height: Self.height)
            .background(Color.customAccent5)
            Button(action: {
                didTapDelete()
            }) {
                Text("DELETE")
                    .font(.bold(size: 14))
                    .foregroundColor(.white)
            }
            .frame(width: Self.sectionWidth, height: Self.height)
        }
        .frame(width: Self.sectionWidth * 2, height: Self.height)
        .background(Color.customBlack)
        .cornerRadius(Self.height / 2)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
    }
}

struct EditInventoryTray_Previews: PreviewProvider {
    static var previews: some View {
        EditInventoryTray(didTapCancel: {}, didTapDelete: {})
    }
}
