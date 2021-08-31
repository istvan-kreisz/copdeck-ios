//
//  FavoritedItem.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/31/21.
//

import Foundation

struct FavoritedItem: Codable, Equatable, Identifiable {
    let id: String
    var itemId: String?
    var name: String
    let imageURL: ImageURL?
    let created: Double?
    let updated: Double?
}
