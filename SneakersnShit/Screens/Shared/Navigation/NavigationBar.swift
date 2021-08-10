//
//  NavigationBar.swift
//  CopDeck
//
//  Created by István Kreisz on 7/18/21.
//

import SwiftUI

struct NavigationBar: View {
    enum Style {
        case light, dark, clear
    }

    @Environment(\.presentationMode) var presentationMode

    let title: String?
    let isBackButtonVisible: Bool
    let style: Style

    static let lightBackgroundColor = Color(r: 233, g: 233, b: 236)

    private var backgroundColor: Color {
        switch style {
        case .dark:
            return Color.customBlack
        case .light:
            return Self.lightBackgroundColor
        case .clear:
            return .clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .dark:
            return .white
        case .light:
            return .customAccent1
        case .clear:
            return .clear
        }
    }


    var body: some View {
        HStack {
            if isBackButtonVisible {
                Button(action: {
                    if style != .clear {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                        ZStack {
                            Circle()
                                .fill(backgroundColor)
                                .frame(width: 38, height: 38, alignment: .center)
                            Image(systemName: "chevron.left")
                                .font(.bold(size: 14))
                                .foregroundColor(foregroundColor)
                        }
                }
            }
            Spacer()
            if let title = title {
                Text(title.uppercased())
                    .font(.bold(size: 12))
                    .foregroundColor(backgroundColor)
                    .padding(.leading, isBackButtonVisible ? -38 : 0)
                    .frame(maxWidth: UIScreen.screenWidth - 180 + (isBackButtonVisible ? 0 : 130))
                    .lineLimit(1)
                    .background(Capsule()
                        .fill(foregroundColor)
                        .frame(height: 38)
                        .padding(.leading, isBackButtonVisible ? -38 : 0))

                Spacer()
            }
        }
        .padding(.top, 30)
        .padding(.bottom, 20)
    }

    static let placeHolder = NavigationBar(title: nil, isBackButtonVisible: true, style: .clear)
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar(title: "yo", isBackButtonVisible: true, style: .light)
    }
}
