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
    static var customBlue = Color("Blue")
    static var customGreen = Color("Green")
    static var customLightGray1 = Color("LightGray1")
    static var customLightGray2 = Color("LightGray2")
    static var customLightGray3 = Color("LightGray3")
    static var customPurple = Color("Purple")
    static var customRed = Color("Red")
    static var customTwitterBlue = Color("TwitterBlue")
    static var customYellow = Color("Yellow")

    static var allCustomColors = [customBackground,
                                  customBlue,
                                  customGreen,
                                  customLightGray1,
                                  customLightGray2,
                                  customLightGray3,
                                  customPurple,
                                  customRed,
                                  customTwitterBlue,
                                  customYellow]
    
    static func randomColor() -> Color {
        allCustomColors.randomElement()!
    }
}

extension UIColor {
    static var customBackground = UIColor(named: "Background")!
    static var customBlue = UIColor(named: "Blue")!
    static var customGreen = UIColor(named: "Green")!
    static var customLightGray1 = UIColor(named: "LightGray1")!
    static var customLightGray2 = UIColor(named: "LightGray2")!
    static var customLightGray3 = UIColor(named: "LightGray3")!
    static var customPurple = UIColor(named: "Purple")!
    static var customRed = UIColor(named: "Red")!
    static var customTwitterBlue = UIColor(named: "TwitterBlue")!
    static var customYellow = UIColor(named: "Yellow")!
}
