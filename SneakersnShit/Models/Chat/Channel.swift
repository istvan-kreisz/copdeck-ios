//
//  Channel.swift
//  CopDeck
//
//  Created by István Kreisz on 10/3/21.
//

import Foundation

struct Channel: Codable, Identifiable, Equatable {
    let id: String
    let userIds: [String]
    let created: Double
    let updated: Double

    var updateInfo: ChatUpdateInfo.ChannelInfo?
    var users: [User] = []

    func messagePartner(userId: String) -> User? {
        users.first(where: { $0.id != userId })
    }

    func hasUnreadMessages(userId: String) -> Bool {
        if let lastMessage = updateInfo?.lastMessage {
            if lastMessage.userId == userId {
                return false
            } else {
                if let lastSeenDate = updateInfo?.lastSeenDate {
                    return lastSeenDate < lastMessage.sentDate
                } else {
                    return true
                }
            }
        } else {
            return false
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, userIds, created, updated
    }
}

extension Channel {
    init(userIds: [String]) {
        self.init(id: UUID().uuidString, userIds: userIds, created: Date.serverDate, updated: Date.serverDate)
    }
}

extension Sequence where Element == Channel {
    func sortedByDate() -> [Element] {
        sorted(by: { (first: Channel, second: Channel) -> Bool in
            if let firstDate = first.updateInfo?.lastMessage?.sentDate {
                if let secondDate = second.updateInfo?.lastMessage?.sentDate {
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
