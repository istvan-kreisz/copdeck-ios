//
//  Channel.swift
//  CopDeck
//
//  Created by István Kreisz on 10/3/21.
//

import Foundation

struct Channel: Codable, Identifiable {
    let id: String
    let users: [String]
    let created: Double
    let updated: Double
}
