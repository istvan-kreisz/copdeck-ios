//
//  ProfileData.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/27/21.
//

import Foundation

struct ProfileData: Codable, Equatable {
    var user: User
    let stacks: [Stack]
    let inventoryItems: [InventoryItem]
}

extension ProfileData: Identifiable {
    var id: String { user.id }
}

extension ProfileData {
    init(user: User) {
        self.init(user: user, stacks: [], inventoryItems: [])
    }
}
