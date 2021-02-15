//
//  File.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/29/21.
//

import Foundation

import UIKit
import SwiftUI

extension Font {
    static func extraLight(size: CGFloat) -> Font { return Font.custom("Karla-ExtraLight", size: size) }
    static func light(size: CGFloat) -> Font { return Font.custom("Nunito-Light", size: size) }
    static func regular(size: CGFloat) -> Font { return Font.custom("Karla-Regular", size: size) }
    static func medium(size: CGFloat) -> Font { return Font.custom("Karla-Medium", size: size) }
    static func semiBold(size: CGFloat) -> Font { return Font.custom("Karla-SemiBold", size: size) }
    static func bold(size: CGFloat) -> Font { return Font.custom("Karla-Bold", size: size) }
    static func extraBold(size: CGFloat) -> Font { return Font.custom("Karla-ExtraBold", size: size) }
}

extension UIFont {
    static var extraLight: UIFont { return UIFont(name: "Karla-ExtraLight", size: 12)! }
    static var light: UIFont { return UIFont(name: "Karla-Light", size: 12)! }
    static var regular: UIFont { return UIFont(name: "Karla-Regular", size: 12)! }
    static var medium: UIFont { return UIFont(name: "Karla-Medium", size: 12)! }
    static var semiBold: UIFont { return UIFont(name: "Karla-SemiBold", size: 12)! }
    static var bold: UIFont { return UIFont(name: "Karla-Bold", size: 12)! }
    static var extraBold: UIFont { return UIFont(name: "Karla-ExtraBold", size: 12)! }
    static var black: UIFont { return UIFont(name: "Karla-Black", size: 12)! }
}
