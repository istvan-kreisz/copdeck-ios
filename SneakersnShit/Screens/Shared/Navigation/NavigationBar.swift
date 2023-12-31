//
//  NavigationBar.swift
//  CopDeck
//
//  Created by István Kreisz on 7/18/21.
//

import SwiftUI

struct NavigationBar: View {
    static let height: CGFloat = 38
    static let botttomPadding: CGFloat = 20
    static var size: CGFloat { height + botttomPadding }
    
    enum Style {
        case light, dark, clear
    }

    enum TitleSize {
        case small, large
    }

    let title: String?
    let isBackButtonVisible: Bool
    var titleFontSize: TitleSize = .small
    let style: Style
    var shouldDismiss: () -> Void

    static let lightBackgroundColor = Color(r: 233, g: 233, b: 236)
    static let titlePadding: CGFloat = 15

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
                        shouldDismiss()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(backgroundColor)
                            .frame(width: Self.height, height: Self.height, alignment: .center)
                        Image(systemName: "chevron.left")
                            .font(.bold(size: 14))
                            .foregroundColor(foregroundColor)
                    }
                }
            }
            Spacer()
            if let title = title {
                Text(title.uppercased())
                    .font(.bold(size: titleFontSize == .small ? 12 : 16))
                    .foregroundColor(backgroundColor)
                    .padding(.leading, isBackButtonVisible ? -Self.height : 0)
                    .frame(maxWidth: UIScreen.screenWidth - 180 - Self.titlePadding * 2 + (isBackButtonVisible ? 0 : 130))
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.horizontal, Self.titlePadding)
                    .background(Capsule()
                        .fill(foregroundColor)
                        .frame(height: Self.height)
                        .padding(.leading, isBackButtonVisible ? -Self.height : 0))
                Spacer()
            }
        }
        .padding(.bottom, Self.botttomPadding)
    }

    static let placeHolder = NavigationBar(title: nil, isBackButtonVisible: true, style: .clear, shouldDismiss: {})
}
