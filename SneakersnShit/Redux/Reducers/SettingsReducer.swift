//
//  SettingsReducer.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation
import Combine

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
