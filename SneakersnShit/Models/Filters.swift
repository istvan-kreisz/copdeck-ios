//
//  Filters.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/21/21.
//

import Foundation

struct Filters: Codable, Equatable {
    enum SoldStatusFilter: String, Codable, Equatable, CaseIterable {
        case sold, unsold, all
    }

    var soldStatus: SoldStatusFilter
}
