//
//  Cookie.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/28/21.
//

import Foundation

struct Cookie: Codable, Equatable {
    let store: StoreId
    let cookie: String?
}
