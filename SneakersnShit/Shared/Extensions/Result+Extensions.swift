//
//  Result+Extensions.swift
//  CopDeck
//
//  Created by István Kreisz on 11/7/21.
//

import Foundation

extension Result {
    var value: Success? {
        guard case let .success(val) = self else { return nil }
        return val
    }
    
    var error: Failure? {
        guard case let .failure(error) = self else { return nil }
        return error
    }
}
