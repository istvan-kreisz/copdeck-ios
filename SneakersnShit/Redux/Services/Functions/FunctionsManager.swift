//
//  FunctionsManager.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Combine

protocol FunctionsManager {
    func search(userId: String, searchTerm: String) -> AnyPublisher<[Item], AppError>
//    func getItemDetails(userId: String, searchTerm: String) -> AnyPublisher<[SearchResult], AppError>
}
