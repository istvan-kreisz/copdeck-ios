//
//  FeedState.swift
//  CopDeck
//
//  Created by István Kreisz on 2/13/23.
//

import Foundation

struct FeedState: Equatable {
    var feedPosts: PaginatedResult<[FeedPost]> = .init(data: [], isLastPage: false)
}
