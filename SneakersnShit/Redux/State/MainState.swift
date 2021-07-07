//
//  MainState.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation

struct MainState: Equatable {
    var userId = ""
    var user: User?
    var searchResults: [Item]?
    var selectedItem: Item?
}
