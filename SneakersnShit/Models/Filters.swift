//
//  Filters.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/21/21.
//

import Foundation

struct Filters: Codable, Equatable {
    enum SoldStatusFilter: String, Equatable, CaseIterable, EnumCodable {
        case Sold, Unsold, All
    }

    var soldStatus: SoldStatusFilter

    static let `default` = Filters(soldStatus: .All)
}
