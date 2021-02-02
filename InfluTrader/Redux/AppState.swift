//
//  AppState.swift
//  InfluTrader
//
//  Created by István Kreisz on 12/13/20.
//

import Foundation

struct SettingsState: Equatable {}

struct ErrorState: Equatable {
    var error: AppError?
}

struct UserIdState: Equatable {
    var userId = ""
}

struct AppState: Equatable {
    var userIdState = UserIdState()
    var errorState = ErrorState()
    var settingState = SettingsState()
    var mainState = MainState()
}
