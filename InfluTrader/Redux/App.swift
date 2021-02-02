//
//  App.swift
//  InfluTrader
//
//  Created by István Kreisz on 12/13/20.
//

import Foundation
import Combine
// import FacebookLogin

enum TradeType: String {
    case buy, sell
}

enum StockQueryType: String {
    case shallow, deep
}

enum StockCategory: String {
    case all, trending, highestValue, highestIncrease, highestDecrease
}

enum FunctionAction {
    case set(mainState: MainState)
    // trade
    case tradeStock(stockId: String, amount: Int, type: TradeType)
    // data feed
    case getStockData
    case getMainFeedData
    case getStocksHistory
    case getStocksInCategory
    // user
    case getUserData
    case changeUsername
    // news
    case getNews
    // search
    case search
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
    case none
    case function(action: FunctionAction)
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
    return Empty(completeImmediately: true).eraseToAnyPublisher()
}

func errorReducer(state: inout ErrorState, action: ErrorAction) -> AnyPublisher<ErrorAction, Never> {
    switch action {
    case let .setError(error: error):
        state.error = error
    }
    return Empty(completeImmediately: true).eraseToAnyPublisher()
}

func authenticatorReducer(state: inout UserIdState,
                          action: AuthenticationAction,
                          environment: Authentication) -> AnyPublisher<AppAction, Never> {
    switch action {
    case let .setUserId(userId):
        state.userId = userId
        return Empty(completeImmediately: true).eraseToAnyPublisher()
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

func mainReducer(state: inout AppState,
                 action: FunctionAction,
                 environment: Main) -> AnyPublisher<AppAction, Never> {
    switch action {
    case let .set(mainState: mainState):
        state.mainState = mainState
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .tradeStock(stockId: stockId, amount: amount, type: type):
        return environment.functions.tradeStock(userId: state.userIdState.userId, stockId: stockId, amount: amount, type: type)
            .map { _ in AppAction.none }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    case .getMainFeedData:
        return environment.functions.getMainFeedData(userId: state.userIdState.userId)
            .map { AppAction.function(action: .set(mainState: $0)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    default:
        return Empty().eraseToAnyPublisher()
    }
}

func appReducer(state: inout AppState,
                action: AppAction,
                environment: World) -> AnyPublisher<AppAction, Never> {
    switch action {
    case .none:
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .function(action: action):
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
