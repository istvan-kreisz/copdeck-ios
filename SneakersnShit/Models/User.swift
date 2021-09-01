//
//  User.swift
//  CopDeck
//
//  Created by István Kreisz on 7/6/21.
//

import Foundation

struct User: Codable, Equatable, Identifiable {
    let id: String
    var inited: Bool?
    var name: String?
    let created: Double?
    let updated: Double?
    var settings: CopDeckSettings?
    var imageURL: URL?

    enum CodingKeys: String, CodingKey {
        case id, inited, name, created, updated, settings
    }
}

extension User {
    init(id: String) {
        self.init(id: id, name: nil, created: nil, updated: nil, settings: nil)
    }
}

extension Array where Element == User {
    var asProfiles: [ProfileData] {
        get {
            map { .init(user: $0, stacks: [], inventoryItems: []) }
        }
        set {}
    }
}
