//
//  UserWithStacks.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/27/21.
//

import Foundation

struct UserWithStacks: Codable, Equatable {
    let user: User
    let stacks: [Stack]
    let inventoryItems: [InventoryItem]
}
