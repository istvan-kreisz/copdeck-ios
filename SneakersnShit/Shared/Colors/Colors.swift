//
//  Colors.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/29/21.
//

import UIKit
import SwiftUI

extension Color {
    static var customBackground = Color("Background")
    static var customBlue = Color(red: 0, green: 2, blue: 252)
    static var customGreen = Color(red: 2, green: 198, blue: 151)
    static var customYellow = Color(red: 253, green: 206, blue: 63)
    static var customOrange = Color(red: 225, green: 121, blue: 80)
    static var customRed = Color(red: 231, green: 57, blue: 91)
    static var customPurple = Color(red: 153, green: 35, blue: 255)
    static var customText1 = Color(red: 21, green: 21, blue: 23)
    static var customText2 = Color(red: 143, green: 146, blue: 161)
    static var customAccent1 = Color(red: 143, green: 146, blue: 161)
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
