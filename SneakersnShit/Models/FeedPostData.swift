//
//  FeedPostData.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/2/21.
//

import Foundation

struct FeedPostData: Codable, Equatable {
    var user: User
    let stack: Stack
    let inventoryItems: [InventoryItem]
}

extension FeedPostData: Identifiable {
    var id: String { stack.id }

    var profileData: ProfileData {
        .init(user: user, stacks: [stack], inventoryItems: inventoryItems)
    }
}
