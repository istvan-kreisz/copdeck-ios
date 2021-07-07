//
//  Stores.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation

typealias AppStore = ReduxStore<AppState, AppAction, World>

typealias MainStore = ReduxStore<MainState, MainAction, Main>

typealias AuthenticationStore = ReduxStore<AuthenticationState, AuthenticationAction, Authentication>
