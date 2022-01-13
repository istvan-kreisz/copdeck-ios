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
}
