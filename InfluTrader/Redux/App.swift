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
    case buy
    case sell
}

enum StockQueryType: String {
    case shallow
    case deep
}

enum StockCategory: String {
    case all
    case trending
    case highestValue
    case highestIncrease
    case highestDecrease
}

enum FunctionAction {
    case setMainState(MainState)
    case setSelectedStock(Stock)
    case setUser(User, String)
    case setStocksHistory([Stock], String)
    case setSelectedStocks([Stock])
    case setSearchResults([String])
    // trade
    case tradeStock(stockId: String, amount: Int, type: TradeType)
    // data feed
    case getStockData(stockId: String, type: StockQueryType)
    case getMainFeedData
    case getStocksHistory(userId: String)
    case getStocksInCategory(category: StockCategory)
    // user
    case getUserData(userId: String)
    case changeUsername(newName: String)
    // news
    case getNews
    // search
    case search(searchTerm: String)
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
        print(userId)
        state.userId = userId
        return Empty(completeImmediately: true).eraseToAnyPublisher()
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
    case let .setMainState(newState):
        state.mainState.user = newState.user
        state.mainState.userStocks = (state.mainState.userStocks ?? []) + (newState.userStocks ?? [])
        state.mainState.trendingStocks = (state.mainState.trendingStocks ?? []) + (newState.trendingStocks ?? [])
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .setSelectedStock(stock):
        state.mainState.selectedStock = stock
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .setUser(user, userId):
        func update(user: inout User?, with newUserData: User?) {
            (newUserData?.cash).map { user?.cash = $0 }
            (newUserData?.starterCash).map { user?.starterCash = $0 }
//            (newUserData?.name).map { user?.name = $0 }
            (newUserData?.transactions).map { user?.transactions = $0 }
        }
        if userId == state.userIdState.userId {
            update(user: &state.mainState.user, with: user)
        } else {
            update(user: &state.mainState.selectedUser, with: user)
        }
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .setStocksHistory(stocks, userId):
        func update(userStocks: inout [Stock]?, with stocks: [Stock]) {
            for stock in stocks {
                if let index = userStocks?.firstIndex(of: stock) {
                    userStocks?[index].stats = stock.stats
                } else {
                    userStocks?.append(stock)
                }
            }
        }
        if userId == state.userIdState.userId {
            update(userStocks: &state.mainState.userStocks, with: stocks)
        } else {
            update(userStocks: &state.mainState.selectedUserStocks, with: stocks)
        }
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .tradeStock(stockId: stockId, amount: amount, type: type):
        return environment.functions.tradeStock(userId: state.userIdState.userId, stockId: stockId, amount: amount, type: type)
            .map { AppAction.function(action: .setMainState($0)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    case let .getStockData(stockId: stockId, type: type):
        return environment.functions.getStockData(userId: state.userIdState.userId, stockId: stockId, type: type)
            .map { AppAction.function(action: .setSelectedStock($0)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    case .getMainFeedData:
        return environment.functions.getMainFeedData(userId: state.userIdState.userId)
            .map { AppAction.function(action: .setMainState($0)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    case let .getStocksHistory(userId: userId):
        return environment.functions.getStocksHistory(userId: userId)
            .map { AppAction.function(action: .setStocksHistory($0, userId)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    case let .getStocksInCategory(category: category):
        return environment.functions.getStocksInCategory(userId: state.userIdState.userId, category: category)
            .map { AppAction.function(action: .setSelectedStocks($0)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    case let .getUserData(userId: userId):
        return environment.functions.getUserData(userId: userId)
            .map { AppAction.function(action: .setUser($0, userId)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    case let .changeUsername(newName: newName):
        let userId = state.userIdState.userId
        return environment.functions.changeUsername(userId: userId, newName: newName)
            .map { AppAction.function(action: .setUser($0, userId)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    case .getNews:
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .search(searchTerm: searchTerm):
        return environment.functions.search(userId: state.userIdState.userId, searchTerm: searchTerm)
            .map { AppAction.function(action: .setSearchResults($0)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
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
