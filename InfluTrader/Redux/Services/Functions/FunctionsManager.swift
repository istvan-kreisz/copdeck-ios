//
//  FunctionsManager.swift
//  InfluTrader
//
//  Created by István Kreisz on 1/30/21.
//

import Foundation
import Combine

protocol FunctionsManager {
    func handle(_ authAction: AuthenticationAction) -> AnyPublisher<String, Error>
}
