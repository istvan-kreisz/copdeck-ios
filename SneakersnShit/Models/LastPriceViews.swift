//
//  LastPriceViews.swift
//  CopDeck
//
//  Created by István Kreisz on 12/19/21.
//

import Foundation

struct LastPriceViews: Codable {
    struct ViewInfo: Codable {
        let itemId: String
        let viewedDate: Double
    }

    let values: [ViewInfo]
}
