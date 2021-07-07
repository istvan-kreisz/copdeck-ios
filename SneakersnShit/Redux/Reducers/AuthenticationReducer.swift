//
//  AuthenticationReducer.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation
import Combine

func authenticatorReducer(state: inout AuthenticationState,
                          action: AuthenticationAction,
                          environment: Authentication) -> AnyPublisher<AppAction, Never> {
    return environment.authenticator.handle(action)
        .map { AppAction.main(action: .setUserId($0)) }
        // todo: revise
        .tryCatch {
            Just(AppAction.main(action: .setUserId(""))).merge(with: Just(AppAction.error(action: .setError(error: AppError(error: $0)))))
        }
        .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
        .eraseToAnyPublisher()
}
