//
//  App.swift
//  SneakersnShit
//
//  Created by István Kreisz on 12/13/20.
//

import Foundation
import Combine
// import FacebookLogin

enum MainAction: IdAble {
    case setUserId(String)
    case setMainState(MainState)
    case setUser(User)
    // data feed
    case getMainFeedData
    // user
    case getUserData(userId: String)
    case changeUsername(newName: String)
    // search
    case search(searchTerm: String)
    case setSearchResults([Item])
}

enum AuthenticationAction: IdAble {
    case restoreState
    case signUp(userName: String, password: String)
    case signIn(userName: String, password: String)
    case signInWithApple
    case signInWithGoogle
    case signInWithFacebook
    case signOut
    case passwordReset(username: String)
//    case setFBLoginButtonDelegate(delegate: LoginButtonDelegate)
}

enum SettingsAction: IdAble {
    case action1
    case action2
}

enum ErrorAction: IdAble {
    case setError(error: AppError?)
}

enum AppAction {
    case none
    case main(action: MainAction)
    case error(action: ErrorAction)
    case authenticator(action: AuthenticationAction)
    case settings(action: SettingsAction)
}

extension AppAction: IdAble {
    var rawValue: String {
        switch self {
        case .none:
            return "AppAction.none"
        case let .main(action):
            return action.id
        case let .error(action):
            return action.id
        case let .authenticator(action):
            return action.id
        case let .settings(action):
            return action.id
        }
    }
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
    return Empty(completeImmediately: true).eraseToAnyPublisher()
}

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

func authenticatorReducer(state: inout UserIdState,
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

func mainReducer(state: inout AppState,
                 action: MainAction,
                 environment: Main) -> AnyPublisher<AppAction, Never> {
    switch action {
    case let .setUserId(userId):
        state.userIdState.userId = userId
        state.mainState.userId = userId
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .setMainState(newState):
        state.mainState = newState
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .setUser(user):
        state.mainState.user = user
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .getUserData(userId: userId):
        print(userId)
//        return environment.functions.getUserData(userId: userId)
//            .map { AppAction.main(action: .setUser($0, userId)) }
//            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
//            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
//            .eraseToAnyPublisher()
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .changeUsername(newName: newName):
        print(newName)
//        let userId = state.mainState.userId
//        return environment.functions.changeUsername(userId: userId, newName: newName)
//            .map { AppAction.main(action: .setUser($0, userId)) }
//            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
//            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
//            .eraseToAnyPublisher()
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .search(searchTerm: searchTerm):
        return environment.functions.search(userId: state.mainState.userId, searchTerm: searchTerm)
            .map { AppAction.main(action: .setSearchResults($0)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    case let .setSearchResults(searchResult):
        state.mainState.searchResults = searchResult
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    default:
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
}

func appReducer(state: inout AppState,
                action: AppAction,
                environment: World) -> AnyPublisher<AppAction, Never> {
    switch action {
    case .none:
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .main(action: action):
        return mainReducer(state: &state, action: action, environment: environment.main)
    case let .authenticator(action: action):
        return authenticatorReducer(state: &state.userIdState, action: action, environment: environment.authentication)
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
