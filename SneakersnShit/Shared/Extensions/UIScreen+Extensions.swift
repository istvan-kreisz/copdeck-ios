//
//  UIScreen+Extensions.swift
//  CopDeck
//
//  Created by István Kreisz on 1/29/21.
//

import UIKit

extension UIScreen {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size

    static var isSmallScreen: Bool {
        screenWidth <= 375
    }
}
