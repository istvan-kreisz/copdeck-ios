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
    var nameInsensitive: String?
    var isPublic: Bool? = true
    let created: Double?
    let updated: Double?
    var settings: CopDeckSettings?
    var imageURL: URL?

    enum CodingKeys: String, CodingKey {
        case id, inited, name, nameInsensitive, isPublic, created, updated, settings
    }
}

extension User {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        inited = try container.decodeIfPresent(Bool.self, forKey: .inited)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        nameInsensitive = try container.decodeIfPresent(String.self, forKey: .nameInsensitive)
        isPublic = true
        created = try container.decodeIfPresent(Double.self, forKey: .created)
        updated = try container.decodeIfPresent(Double.self, forKey: .updated)
        settings = try container.decodeIfPresent(CopDeckSettings.self, forKey: .settings)
    }

    init(id: String) {
        self.init(id: id, name: nil, nameInsensitive: nil, isPublic: true, created: nil, updated: nil, settings: nil)
    }

    func withImageURL(_ url: URL?) -> User {
        var copy = self
        copy.imageURL = url
        return copy
    }
}

extension Array where Element == User {
    var asProfiles: [ProfileData] {
        get { self.map { .init(user: $0, stacks: [], inventoryItems: []) } }
        set {}
    }
}
