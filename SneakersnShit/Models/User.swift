//
//  User.swift
//  CopDeck
//
//  Created by István Kreisz on 7/6/21.
//

import Foundation

struct User: Codable, Equatable {
    let id: String
    let name: String?
    let created: Double?
    let updated: Double?
    let settings: CopDeckSettings?
}

extension User {
    init(id: String) {
        self.init(id: id, name: nil, created: nil, updated: nil, settings: nil)
    }
}
