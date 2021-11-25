//
//  Tag.swift
//  CopDeck
//
//  Created by István Kreisz on 11/8/21.
//

import Foundation
import SwiftUI

struct Tag: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    let color: String
}

extension Tag {
    init(name: String, color: String) {
        self.init(id: UUID().uuidString, name: name, color: color)
    }
}

extension Tag {
    static let sold = Tag(id: "sold", name: "sold", color: "red")
    static let shipping = Tag(id: "shipping", name: "shipping", color: "blue")
    
    static let defaultTags = [sold, shipping]
    
    static let allColors = ["blue", "green", "purple", "red", "yellow"]
    
    static func color(_ colorName: String) -> Color {
        switch colorName {
        case "blue":
            return .customBlue
        case "green":
            return .customGreen
        case "purple":
            return .customPurple
        case "red":
            return .customRed
        case "yellow":
            return .customYellow
        default:
            return .customBlue
        }
    }
    
    var uiColor: Color {
        Self.color(color)
    }
}
