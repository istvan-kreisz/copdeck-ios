//
//  AppReducer.swift
//  CopDeck
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation
import Combine
import Firebase

func appReducer(state: inout AppState,
                action: AppAction,
                environment: World,
                completed: ((Result<Void, AppError>) -> Void)?) -> AnyPublisher<AppAction, Never> {
    log("processing: \(action.id)", logType: .reduxAction)
    switch action {
    case let .main(action: action):
        return mainReducer(state: &state, action: action, environment: environment, completed: completed)
    case let .authentication(action):
        return authReducer(state: &state, action: action, environment: environment, completed: completed)
    case let .paymentAction(action):
        return paymentReducer(state: &state, action: action, environment: environment, completed: completed)
    case let .error(action: action):
        switch action {
        case let .setError(error: error):
            state.error = error
        }
    case .none:
        break
    }
    return Empty(completeImmediately: true).eraseToAnyPublisher()
}
