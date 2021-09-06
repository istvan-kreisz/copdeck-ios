//
//  FeedPost.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/2/21.
//

import Foundation

struct FeedPost: Codable, Equatable {
    let userId: String
    let stack: Stack
    let inventoryItems: [InventoryItem]

    var user: User?
}

extension FeedPost: Identifiable {
    var id: String { stack.id }

    var profileData: ProfileData? {
        user.map { .init(user: $0, stacks: [stack], inventoryItems: inventoryItems) }
    }
}

extension FeedPost: ModelWithDate {
    var created: Double? {
        stack.publishedDate
    }

    var updated: Double? {
        stack.updated
    }
}
