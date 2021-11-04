//
//  ChatUpdateInfo.swift
//  CopDeck
//
//  Created by István Kreisz on 11/4/21.
//

import Foundation

struct ChatUpdateInfo: Codable, Equatable {
    struct LastMessage: Codable, Equatable {
        let userId: String
        let content: String
        let sentDate: Double
    }
    struct ChannelInfo: Codable, Equatable {
        let channelId: String
        let lastSeenDate: Double?
        let lastMessage: LastMessage?
    }

    let updateInfo: [String: ChannelInfo]
    
    var updates: [ChannelInfo] {
        Array(updateInfo.values)
    }
}
