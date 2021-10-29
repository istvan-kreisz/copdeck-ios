//
//  Styles.swift
//  CopDeck
//
//  Created by István Kreisz on 7/18/21.
//

import SwiftUI

enum Styles {
    static let horizontalMargin: CGFloat = { UIScreen.isSmallScreen ? 17 : 26 }()
    static let horizontalPadding: CGFloat = { UIScreen.isSmallScreen ? 12 : 16 }()
    static let verticalPadding: CGFloat = 15
    static let inputFieldHeight: CGFloat = 42
    static let inputFieldHeightLarge: CGFloat = 120
    static let cornerRadius: CGFloat = 12
    static let tabScreenBottomPadding: CGFloat = 130
}
