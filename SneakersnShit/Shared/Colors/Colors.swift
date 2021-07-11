//
//  Colors.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/29/21.
//

import UIKit
import SwiftUI

extension Color {
    init(r: Int, g: Int, b: Int) {
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }

    static var customBackground = Color("Background")
    static var customBlue = Color(r: 0, g: 2, b: 252)
    static var customGreen = Color(r: 2, g: 198, b: 151)
    static var customYellow = Color(r: 253, g: 206, b: 63)
    static var customOrange = Color(r: 225, g: 121, b: 80)
    static var customRed = Color(r: 231, g: 57, b: 91)
    static var customPurple = Color(r: 153, g: 35, b: 255)
    static var customText1 = Color(r: 21, g: 21, b: 23)
    static var customText2 = Color(r: 143, g: 146, b: 161)
    static var customAccent1 = Color(r: 143, g: 146, b: 161)
    static var customAccent2 = Color.black.opacity(0.1)
    static var customTwitterBlue = Color("TwitterBlue") // #00ACEC

    static var allCustomColors = [customBackground,
                                  customBlue,
                                  customGreen,
                                  customPurple,
                                  customRed,
                                  customTwitterBlue,
                                  customYellow]

    static func randomColor() -> Color {
        allCustomColors.randomElement()!
    }
}

//extension UIColor {
//    static var customBackground = UIColor(named: "Background")!
//    static var customBlue = UIColor(named: "Blue")!
//    static var customGreen = UIColor(named: "Green")!
//    static var customLightGray1 = UIColor(named: "LightGray1")!
//    static var customLightGray2 = UIColor(named: "LightGray2")!
//    static var customLightGray3 = UIColor(named: "LightGray3")!
//    static var customPurple = UIColor(named: "Purple")!
//    static var customRed = UIColor(named: "Red")!
//    static var customTwitterBlue = UIColor(named: "TwitterBlue")!
//    static var customYellow = UIColor(named: "Yellow")!
//}
