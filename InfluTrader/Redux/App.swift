//
//  App.swift
//  InfluTrader
//
//  Created by István Kreisz on 12/13/20.
//

import Foundation
import Combine

enum GlobalErrors: Error {
    case unknown
}

enum AuthenticationAction {
    case signUp(userName: String, password: String)
    case signIn(userName: String, password: String)
    case signInWithApple
    case signInWithGoogle
    case signInWithFacebook
    case signOut
    case passwordReset(username: String)
    case setUserId(userId: String)
}

enum SettingsAction {
    case action1
    case action2
}

enum ErrorAction {
    case setError(error: Error?)
}

enum AppAction {
    case error(action: ErrorAction)
    case authenticator(action: AuthenticationAction)
    case settings(action: SettingsAction)
}

func settingReducer(state: inout SettingsState,
                    action: SettingsAction,
                    environment: AppSettings) -> AnyPublisher<SettingsAction, Never> {
    switch action {
    case .action1:
        state = SettingsState()
    case .action2:
        break
//        return environment.service
//            .publisher
//            .replaceError(with: ())
//            .map { TrendsAction.action1 }
//            .eraseToAnyPublisher()
    }
    return Empty().eraseToAnyPublisher()
}

func errorReducer(state: inout ErrorState, action: ErrorAction) -> AnyPublisher<ErrorAction, Never> {
    switch action {
    case let .setError(error: error):
        state.error = error
    }
    return Empty().eraseToAnyPublisher()
}

func authenticatorReducer(state: inout UserState,
                          action: AuthenticationAction,
                          environment: Authentication) -> AnyPublisher<AppAction, Never> {
    switch action {
    case let .setUserId(userId):
        state.userId = userId
        return Empty().eraseToAnyPublisher()
    default:
        return environment.authenticator.handle(action)
            .map { AppAction.authenticator(action: .setUserId(userId: $0)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: $0))) }
            .replaceError(with: AppAction.error(action: .setError(error: GlobalErrors.unknown)))
            .eraseToAnyPublisher()
    }
}

func appReducer(state: inout AppState,
                action: AppAction,
                environment: Environment) -> AnyPublisher<AppAction, Never> {
    switch action {
    case let .authenticator(action: action):
        return authenticatorReducer(state: &state.userState, action: action, environment: environment.authentication)
    case let .error(action: action):
        return errorReducer(state: &state.errorState, action: action)
            .map(AppAction.error)
            .eraseToAnyPublisher()
    case let .settings(action: action):
        return settingReducer(state: &state.settingState, action: action, environment: environment.settings)
            .map(AppAction.settings)
            .eraseToAnyPublisher()
    }
}

typealias AppStore = Store<AppState, AppAction, Environment>
