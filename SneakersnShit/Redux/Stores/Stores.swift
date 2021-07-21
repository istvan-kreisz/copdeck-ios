//
//  Stores.swift
//  CopDeck
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation

typealias AppStore = ReduxStore<AppState, AppAction, World>

extension AppStore {
    static let `default` = AppStore(state: .init(), reducer: appReducer, environment: World())
}
