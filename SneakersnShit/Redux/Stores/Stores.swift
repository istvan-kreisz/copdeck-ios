//
//  Stores.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation

typealias AppStore = ReduxStore<AppState, AppAction, App>

extension AppStore {
    static let `default` = AppStore(initialState: .init(), reducer: appReducer, environment: App())
}
