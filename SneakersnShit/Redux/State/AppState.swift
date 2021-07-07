//
//  AppState.swift
//  SneakersnShit
//
//  Created by István Kreisz on 12/13/20.
//

import Foundation

struct AppState: Equatable {
    var authenticationState = AuthenticationState()
    var errorState = ErrorState()
    var settingState = SettingsState()
    var mainState = MainState()
}

extension AppState {
    static var mockAppState: AppState = .init(authenticationState: .init(userId: "Kd24f2VebTWpTYYqAkSeHZwWhB83"),
                                              errorState: .init(error: nil),
                                              settingState: .init(),
                                              mainState: .init(userId: "", user: nil, searchResults: nil))
}
