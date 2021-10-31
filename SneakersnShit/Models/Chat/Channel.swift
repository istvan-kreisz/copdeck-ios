//
//  Channel.swift
//  CopDeck
//
//  Created by István Kreisz on 10/3/21.
//

import Foundation

struct Channel: Codable, Identifiable {
    struct LastMessage: Codable {
        let userId: String
        let content: String
    }

    let id: String
    let userIds: [String]
    let lastMessage: LastMessage?
    let created: Double
    let updated: Double

    var users: [User] = []
    var unreadCount = 0
    
    
    func messagePartner(userId: String) -> User? {
        users.first(where: { $0.id != userId })
    }

    enum CodingKeys: String, CodingKey {
        case id, userIds, lastMessage, created, updated
    }
}

extension Channel {
    init(userIds: [String]) {
        self.init(id: UUID().uuidString,
                  userIds: userIds,
                  lastMessage: nil,
                  created: Date.serverDate,
                  updated: Date.serverDate)
    }
}
