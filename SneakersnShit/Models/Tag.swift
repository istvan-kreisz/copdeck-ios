//
//  Tag.swift
//  CopDeck
//
//  Created by István Kreisz on 11/8/21.
//

import Foundation

struct Tag: Codable, Equatable {
    let id: String
    let name: String
    let color: String
}

extension Tag {
    static let sold = Tag(id: "sold", name: "sold", color: "red")
    static let shipping = Tag(id: "shipping", name: "shipping", color: "blue")
    
    static let defaultTags = [sold, shipping]
}
