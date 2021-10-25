//
//  File.swift
//  CopDeck
//
//  Created by István Kreisz on 1/29/21.
//

import Foundation

import UIKit
import SwiftUI

extension Font {
    static func extraLight(size: CGFloat) -> Font { return Font.custom("Karla-ExtraLight", size: size) }
    static func light(size: CGFloat) -> Font { return Font.custom("Karla-Light", size: size) }
    static func regular(size: CGFloat) -> Font { return Font.custom("Karla-Regular", size: size) }
    static func medium(size: CGFloat) -> Font { return Font.custom("Karla-Medium", size: size) }
    static func semiBold(size: CGFloat) -> Font { return Font.custom("Karla-SemiBold", size: size) }
    static func bold(size: CGFloat) -> Font { return Font.custom("Karla-Bold", size: size) }
    static func extraBold(size: CGFloat) -> Font { return Font.custom("Karla-ExtraBold", size: size) }
}

extension UIFont {
    static func extraLight(size: CGFloat) -> UIFont { UIFont(name: "Karla-ExtraLight", size: size)! }
    static func light(size: CGFloat) -> UIFont { UIFont(name: "Karla-Light", size: size)! }
    static func regular(size: CGFloat) -> UIFont { UIFont(name: "Karla-Regular", size: size)! }
    static func medium(size: CGFloat) -> UIFont { UIFont(name: "Karla-Medium", size: size)! }
    static func semiBold(size: CGFloat) -> UIFont { UIFont(name: "Karla-SemiBold", size: size)! }
    static func bold(size: CGFloat) -> UIFont { UIFont(name: "Karla-Bold", size: size)! }
    static func extraBold(size: CGFloat) -> UIFont { UIFont(name: "Karla-ExtraBold", size: size)! }
    static func black(size: CGFloat) -> UIFont { UIFont(name: "Karla-Black", size: size)! }
}
