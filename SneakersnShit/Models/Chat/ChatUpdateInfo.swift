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
        var channelId: String?
        let lastSeenDate: Double?
        let lastMessage: LastMessage?
        
        enum CodingKeys: String, CodingKey {
            case lastSeenDate, lastMessage
        }
    }

    let updateInfo: [String: ChannelInfo]
    
    var updates: [ChannelInfo] {
        updateInfo.map { info in
            var infoWithId = info.value
            infoWithId.channelId = info.key
            return infoWithId
        }
    }
}
