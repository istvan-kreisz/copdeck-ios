//
//  App.swift
//  SneakersnShit
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

enum MainAction {
    case setUserId(String)
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

enum SettingsAction {
    case action1
    case action2
}

enum ErrorAction {
    case setError(error: AppError?)
}

enum AppAction {
    case none
    case main(action: MainAction)
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
        #if DEBUG
        if let errorDescription = error?.localizedDescription {
            print("--------------")
            print(errorDescription)
            print("--------------")
        }
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
            (newUserData?.name).map { user?.name = $0 }
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
        return environment.functions.tradeStock(userId: state.mainState.userId, stockId: stockId, amount: amount, type: type)
            .map { AppAction.main(action: .setMainState($0)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    case let .getStockData(stockId: stockId, type: type):
        return environment.functions.getStockData(userId: state.mainState.userId, stockId: stockId, type: type)
            .map { AppAction.main(action: .setSelectedStock($0)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    case .getMainFeedData:
        return environment.functions.getMainFeedData(userId: state.mainState.userId)
            .map { AppAction.main(action: .setMainState($0)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    case let .getStocksHistory(userId: userId):
        return environment.functions.getStocksHistory(userId: userId)
            .map { AppAction.main(action: .setStocksHistory($0, userId)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    case let .getStocksInCategory(category: category):
        return environment.functions.getStocksInCategory(userId: state.mainState.userId, category: category)
            .map { AppAction.main(action: .setSelectedStocks($0)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    case let .getUserData(userId: userId):
        return environment.functions.getUserData(userId: userId)
            .map { AppAction.main(action: .setUser($0, userId)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    case let .changeUsername(newName: newName):
        let userId = state.mainState.userId
        return environment.functions.changeUsername(userId: userId, newName: newName)
            .map { AppAction.main(action: .setUser($0, userId)) }
            .tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    case .getNews:
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    case let .search(searchTerm: searchTerm):
        return environment.functions.search(userId: state.mainState.userId, searchTerm: searchTerm)
            .map { AppAction.main(action: .setSearchResults($0)) }
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
