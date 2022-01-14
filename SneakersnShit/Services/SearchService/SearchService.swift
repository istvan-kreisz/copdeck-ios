//
//  SearchService.swift
//  CopDeck
//
//  Created by István Kreisz on 1/13/22.
//

import Foundation
import AlgoliaSearchClient

protocol SearchService {
    func setup(apiKey: APIKey)
    func search(searchTerm: String, completion: @escaping (Result<[ItemSearchResult], AppError>) -> Void)
}
