//
//  UserDetailView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/29/21.
//

import SwiftUI

struct UserDetailView: View {
    let name: String
    let value: String
    var showCopyButton: Bool = true
    var color: Color = .customText1

    var body: some View {
        HStack(spacing: 3) {
            Text("\(name):")
                .font(.bold(size: 15))
                .foregroundColor(.customText1)
                .lineLimit(1)
                .layoutPriority(3)
            Text(value)
                .font(.regular(size: 15))
                .foregroundColor(color)
                .lineLimit(1)
                .layoutPriority(2)
            Spacer()
                .layoutPriority(1)
            if showCopyButton {
                Button {
                    UIPasteboard.general.string = value
                } label: {
                    Text("Copy")
                        .font(.bold(size: 15))
                        .foregroundColor(.customBlue)
                        .lineLimit(1)
                }
                .layoutPriority(3)
            }
        }
    }
}
