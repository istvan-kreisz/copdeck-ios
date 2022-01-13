//
//  ItemSearchResult.swift
//  CopDeck
//
//  Created by István Kreisz on 1/13/22.
//

import Foundation

struct ItemSearchResult: Codable, Equatable, Identifiable {
    let id: String
    let styleId: String?
    let name: String?
    let imageURL: ImageURL?
    let created: Double?
    let updated: Double?
}

extension ItemSearchResult: ModelWithDate {}

extension ItemSearchResult {
    init(from item: Item) {
        self.id = item.id
        self.styleId = item.styleId
        self.name = item.name
        self.imageURL = item.imageURL
        self.created = item.created
        self.updated = item.updated
    }
}

extension Array where Element == ItemSearchResult {
    func removeDuplicateElements() -> [ItemSearchResult] {
        var uniqueElements = [ItemSearchResult]()
        for element in self {
            if !uniqueElements.contains(where: { $0.id == element.id }) {
                uniqueElements.append(element)
            }
        }
        return uniqueElements
    }
}
