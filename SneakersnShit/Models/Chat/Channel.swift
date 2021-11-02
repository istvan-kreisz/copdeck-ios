//
//  Channel.swift
//  CopDeck
//
//  Created by István Kreisz on 10/3/21.
//

import Foundation

struct Channel: Codable, Identifiable, Equatable {
    struct LastMessage: Codable, Equatable {
        let userId: String
        let content: String
        let sentDate: Double
    }

    let id: String
    let userIds: [String]
    var lastMessages: [String: LastMessage]
    var lastSeenDates: [String: Double]
    let created: Double
    var updated: Double
    var lastMessageSentDate: Double?

    var users: [User] = []
    
    var lastMessage: LastMessage? {
        lastMessages.values.sorted(by: { $0.sentDate < $1.sentDate }).last
    }

    func lastMessageSent(byUserWithId id: String) -> LastMessage? {
        lastMessages[id]
    }

    func messagePartner(userId: String) -> User? {
        users.first(where: { $0.id != userId })
    }

    func hasUnreadMessages(userId: String) -> Bool {
        let lastSeenDate = lastSeenDates[userId] ?? Date(timeIntervalSince1970: 0).timeIntervalSince1970 * 1000
        let lastMessagesByOthers = userIds.filter { $0 != userId }.compactMap(lastMessageSent)
        
        return lastMessagesByOthers.contains(where: { $0.sentDate > lastSeenDate })
    }

    enum CodingKeys: String, CodingKey {
        case id, userIds, lastMessages, lastSeenDates, created, updated, lastMessageSentDate
    }
}

extension Channel {
    init(userIds: [String]) {
        self.init(id: UUID().uuidString,
                  userIds: userIds,
                  lastMessages: [:],
                  lastSeenDates: [:],
                  created: Date.serverDate,
                  updated: Date.serverDate,
                  lastMessageSentDate: nil)
    }
}

extension Sequence where Element == Channel {
    func sortedByDate() -> Array<Element> {
        sorted(by: { (first: Channel, second: Channel) -> Bool in
            if let firstDate = first.lastMessageSentDate {
                if let secondDate = second.lastMessageSentDate {
                    return firstDate > secondDate
                } else {
                    return true
                }
            } else {
                return false
            }
        })
    }
}
