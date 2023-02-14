//
//  InventoryState.swift
//  CopDeck
//
//  Created by István Kreisz on 2/13/23.
//

import Foundation

struct InventoryState: Equatable {
    var inventoryItems: [InventoryItem] = []
    var stacks: [Stack] = []
    var profileImageURL: URL?
}
