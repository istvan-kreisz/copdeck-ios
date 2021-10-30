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

extension Channel {
    init(users: [String]) {
        self.init(id: UUID().uuidString, users: users, created: Date.serverDate, updated: Date.serverDate)
    }
}
