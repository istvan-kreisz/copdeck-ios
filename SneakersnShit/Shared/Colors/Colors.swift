//
//  Colors.swift
//  CopDeck
//
//  Created by István Kreisz on 1/29/21.
//

import UIKit
import SwiftUI

extension Color {
    init(r: Int, g: Int, b: Int, opacity: Double = 1) {
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: opacity)
    }

    static var customBackground = Color("Background")
    static var customBlack = Color(r: 23, g: 23, b: 23)
    static var customWhite = Color(r: 255, g: 255, b: 255)
    static var customBlue = Color(r: 0, g: 2, b: 252)
    static var customGreen = Color(r: 2, g: 198, b: 151)
    static var customYellow = Color(r: 253, g: 206, b: 63)
    static var customOrange = Color(r: 225, g: 121, b: 80)
    static var customRed = Color(r: 231, g: 57, b: 91)
    static var customPurple = Color(r: 153, g: 35, b: 255)
    static var customText1 = Color(r: 21, g: 21, b: 23)
    static var customText2 = Color(r: 143, g: 146, b: 161)
    static var customAccent1 = Color(r: 143, g: 146, b: 161)
    static var customAccent2 = Color.customAccent1.opacity(0.2)
    static var customAccent3 = Color.black.opacity(0.1)
    static var customAccent4 = Color(r: 243, g: 246, b: 248)
    static var customAccent5 = Color(r: 69, g: 69, b: 69)
    static var customTwitterBlue = Color("TwitterBlue") // #00ACEC

    static var allCustomColors = [customBackground,
                                  customBlue,
                                  customGreen,
                                  customPurple,
                                  customRed,
                                  customTwitterBlue,
                                  customYellow]

    static var pillColors = [customBlue,
                             customGreen,
                             customPurple,
                             customRed,
                             customYellow]

    static var randomColor: Color {
        allCustomColors.randomElement()!
    }

    static var randomPillColor: Color {
        pillColors.randomElement()!
    }
}

 extension UIColor {
     static var messageColors: [UIColor] = {
         let colors: [Color] = [.customBlue, .customPurple, .customOrange, .customGreen, .customRed]
         return colors.map { UIColor($0) }
     }()
 }
