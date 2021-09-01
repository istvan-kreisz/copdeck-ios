//
//  ProfileData.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/27/21.
//

import Foundation

struct ProfileData: Codable, Equatable {
    let user: User
    let stacks: [Stack]
    let inventoryItems: [InventoryItem]
}

extension ProfileData: Identifiable {
    var id: String { user.id }
}
