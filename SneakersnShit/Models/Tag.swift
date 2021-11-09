//
//  Tag.swift
//  CopDeck
//
//  Created by István Kreisz on 11/8/21.
//

import Foundation
import SwiftUI

struct Tag: Codable, Equatable {
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
    
    var uiColor: Color {
        switch color {
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
}
