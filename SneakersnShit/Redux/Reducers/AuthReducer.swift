//
//  AuthReducer.swift
//  CopDeck
//
//  Created by István Kreisz on 2/13/23.
//

import Foundation
import Combine
import Firebase

func authReducer(state: inout AppState,
                 action: AuthenticationAction,
                 environment: World,
                 completed: ((Result<Void, AppError>) -> Void)?) -> AnyPublisher<AppAction, Never> {
    let result: AnyPublisher<String, Error>
    switch action {
    case .restoreState:
        result = environment.authenticator.restoreState()
    case let .signUp(username, password):
        result = environment.authenticator.signUp(email: username, password: password)
    case let .signIn(username, password):
        result = environment.authenticator.signIn(email: username, password: password)
    case .signInWithApple:
        result = environment.authenticator.signInWithApple()
    case .signInWithGoogle:
        result = environment.authenticator.signInWithGoogle()
//        case .signInWithFacebook:
//            let user = state.user
//            let publisher = environment.authenticator.signInWithFacebook()
//                .handleEvents(receiveOutput: { [weak environment] _, profileURL in
//                    if var profile = user {
//                        profile.facebookProfileURL = profileURL
//                        environment?.dataController.update(user: profile)
//                    }
//                })
//                .map(\.userId)
//                .eraseToAnyPublisher()
//            result = publisher
    case let .passwordReset(email):
        result = environment.authenticator.resetPassword(email: email)
    case .signOut:
        result = environment.authenticator.signOut()
    case .deleteAccount:
        environment.dataController.deleteAccount()
        result = environment.authenticator.signOut()
    }
    return result
        .flatMap { userId -> AnyPublisher<AppAction, Never> in
            if userId.isEmpty {
                return Just(AppAction.main(action: .signOut)).eraseToAnyPublisher()
            } else {
                return environment.dataController.getUser(withId: userId)
                    .flatMap { (user: User) -> AnyPublisher<AppAction, Never> in
                        Just(AppAction.main(action: .setUser(user: user))).eraseToAnyPublisher()
                    }
                    .tryCatch {
                        Just(AppAction.main(action: .signOut)).merge(with: Just(AppAction.error(action: .setError(error: AppError(error: $0)))))
                    }
                    .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
                    .eraseToAnyPublisher()
            }
        }
        .tryCatch {
            Just(AppAction.error(action: .setError(error: AppError(error: $0))))
        }
        .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
        .eraseToAnyPublisher()
}
