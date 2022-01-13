//
//  SearchService.swift
//  CopDeck
//
//  Created by István Kreisz on 1/13/22.
//

import Foundation

protocol SearchService {
    func search(searchTerm: String, completion: @escaping (Result<[ItemSearchResult], AppError>) -> Void)
}
