//
//  DefaultSearchService.swift
//  CopDeck
//
//  Created by István Kreisz on 1/13/22.
//

import Foundation
import AlgoliaSearchClient

class DefaultSearchService: SearchService {
    private let index: Index

    #warning("apikey")
    init(apiKey: String = "b9d0f9b52c15f781fbb21e5cb853c726") {
        let client = SearchClient(appID: "33I8B9A08E", apiKey: "b9d0f9b52c15f781fbb21e5cb853c726")
        index = client.index(withName: "items")
    }

    func search(searchTerm: String, completion: @escaping (Result<[ItemSearchResult], AppError>) -> Void) {
        var query = Query(searchTerm)
        query.hitsPerPage = 100
        index.search(query: query) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.init(error: error)))
            case let .success(response):
                let results = response.hits.compactMap { (hit: Hit<JSON>) -> ItemSearchResult? in
                    if let object = hit.object.object() {
                        return ItemSearchResult(from: object)
                    } else {
                        return nil
                    }
                }
                completion(.success(results))
            }
        }
    }
}
