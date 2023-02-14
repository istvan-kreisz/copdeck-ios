//
//  PaginatedResult.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/4/21.
//

import SwiftUI

struct PaginatedResult<T: Codable & Equatable>: Codable, Equatable {
    var data: T
    var isLastPage: Bool
}

struct PaginationState<T> {
    var lastLoaded: T?
    var isLastPage: Bool

    mutating func reset() {
        self = .init(lastLoaded: nil, isLastPage: false)
    }
}
