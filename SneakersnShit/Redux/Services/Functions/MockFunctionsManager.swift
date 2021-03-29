//
//  MockFunctionsManager.swift
//  SneakersnShit
//
//  Created by István Kreisz on 2/14/21.
//

import Foundation

import Foundation
import Combine
import FirebaseFunctions

class MockFunctionsManager: FunctionsManager {
    func search(userId: String, searchTerm: String) -> AnyPublisher<[Item], AppError> {
        Empty().eraseToAnyPublisher()
    }

    init() {}
}
