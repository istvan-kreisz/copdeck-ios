//
//  AppState.swift
//  InfluTrader
//
//  Created by István Kreisz on 12/13/20.
//

import Foundation


struct ErrorState: Equatable {
    var error: Error?
    
    static func == (_ lhs: ErrorState, _ rhs: ErrorState) -> Bool {
        lhs.error?.localizedDescription == rhs.error?.localizedDescription
    }
}

struct UserState: Equatable {
    var userId = ""
}

struct SettingsState: Equatable {}

struct AppState: Equatable {
    var userState = UserState()
    var errorState = ErrorState()
    var settingState = SettingsState()
}
