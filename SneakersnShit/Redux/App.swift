//
//  App.swift
//  SneakersnShit
//
//  Created by István Kreisz on 12/13/20.
//

import Foundation
import Combine
// import FacebookLogin

enum MainAction {
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
    // item details
    case getItemDetails(item: Item)
    case setItemDetails(item: Item)
}

extension MainAction: IdAble {
    var id: String {
        switch self {
        case .setUserId:
            return "setUserId"
        case .setMainState:
            return "setMainState"
        case .setUser:
            return "setUser"
        case .getMainFeedData:
            return "getMainFeedData"
        case .getUserData:
            return "getUserData"
        case .changeUsername:
            return "changeUsername"
        case .search:
            return "search"
        case .setSearchResults:
            return "setSearchResults"
        case .getItemDetails:
            return "getItemDetails"
        case .setItemDetails:
            return "setItemDetails"
        }
    }
}


enum AuthenticationAction {
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

extension AuthenticationAction: IdAble {
    var id: String {
        switch self {
        case .restoreState:
            return "restoreState"
        case .signUp:
            return "signUp"
        case .signIn:
            return "signIn"
        case .signInWithApple:
            return "signInWithApple"
        case .signInWithGoogle:
            return "signInWithGoogle"
        case .signInWithFacebook:
            return "signInWithFacebook"
        case .signOut:
            return "signOut"
        case .passwordReset:
            return "passwordReset"
        }
    }
}

enum SettingsAction {
    case action1
    case action2
}

extension SettingsAction: IdAble {
    var id: String {
        switch self {
        case .action1:
            return "action1"
        case .action2:
            return "action2"
        }
    }
}


enum ErrorAction {
    case setError(error: AppError?)
}

extension ErrorAction: IdAble {
    var id: String {
        switch self {
        case .setError:
            return "setError"
        }
    }
}

enum AppAction {
    case none
    case main(action: MainAction)
    case error(action: ErrorAction)
    case authenticator(action: AuthenticationAction)
    case settings(action: SettingsAction)
}

extension AppAction: IdAble {
    var id: String {
        var actionName = "AppAction."
        switch self {
        case .none:
            actionName += "none"
        case let .main(action):
            actionName += action.id
        case let .error(action):
            actionName += action.id
        case let .authenticator(action):
            actionName += action.id
        case let .settings(action):
            actionName += action.id
        }
        return actionName
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
        if searchTerm.isEmpty {
            return Just(AppAction.main(action: .setSearchResults([])))
                .eraseToAnyPublisher()
        } else {
            return environment.functions.search(userId: state.mainState.userId, searchTerm: searchTerm)
                .map { AppAction.main(action: .setSearchResults($0)) }
                .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
                .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
                .eraseToAnyPublisher()
        }
    case let .setSearchResults(searchResult):
        state.mainState.searchResults = searchResult
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .getItemDetails(item):
        return environment.functions.getItemDetails(for: item)
            .map { AppAction.main(action: .setItemDetails(item: $0)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    case let .setItemDetails(item):
        state.mainState.selectedItem = item
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
