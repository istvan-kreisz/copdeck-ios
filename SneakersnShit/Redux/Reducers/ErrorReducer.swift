//
//  ErrorReducer.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation
import Combine

func errorReducer(state: inout ErrorState, action: ErrorAction) -> AnyPublisher<ErrorAction, Never> {
    switch action {
    case let .setError(error: error):
        #if DEBUG
            print("--------------")
            print(error?.title ?? "")
            print(error?.message ?? "")
            print(error?.error ?? "")
            print("--------------")
        #endif
        state.error = error
    }
    return Empty(completeImmediately: true).eraseToAnyPublisher()
}
