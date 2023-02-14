//
//  SearchState.swift
//  CopDeck
//
//  Created by István Kreisz on 2/13/23.
//

import Foundation

class SearchModel: ObservableObject {
    @Published var state = SearchState()
}

struct SearchState: Equatable {
    struct SearchResults: Equatable {
        let searchTerm: String
        var searchResults: [ItemSearchResult] = []
    }
    
    var searchResults = SearchResults(searchTerm: "")
    var popularItems: [ItemSearchResult] = []
    var userSearchResults: [User] = []
}
