//
//  App.swift
//  InfluTrader
//
//  Created by István Kreisz on 12/13/20.
//

import Foundation
import Combine
//import FacebookLogin

struct AppError: Identifiable {
    let id = UUID().uuidString
    let title: String
    let message: String
    let error: Error?

    init(title: String = "Ooops", message: String = "Unknown Error", error: Error? = nil) {
        self.title = title
        self.message = message
        self.error = error
    }
    
    init(error: Error) {
        self.init(title: "", message: "", error: error)
    }
    
    static var unknown: Self = .init(title: "", message: "")
}

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
//    case setFBLoginButtonDelegate(delegate: LoginButtonDelegate)
}

enum SettingsAction {
    case action1
    case action2
}

enum ErrorAction {
    case setError(error: AppError?)
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
//    case let .setFBLoginButtonDelegate(delegate):
//        delegate = environment.authenticator
//        return Empty().eraseToAnyPublisher()
    default:
        return environment.authenticator.handle(action)
            .map { AppAction.authenticator(action: .setUserId(userId: $0)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    }
}

func appReducer(state: inout AppState,
                action: AppAction,
                environment: World) -> AnyPublisher<AppAction, Never> {
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

typealias AppStore = Store<AppState, AppAction, World>
