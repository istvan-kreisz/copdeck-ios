//
//  AppAction.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation

enum AppAction {
    case none
    case main(action: MainAction)
    case error(action: ErrorAction)
    case authenticator(action: AuthenticationAction)
}

extension AppAction: IdAble {
    var id: String {
        var actionName = "AppAction."
        switch self {
        case .none:
            actionName += "none"
        case let .main(action):
            actionName += action.id
        case let .error(action):
            actionName += action.id
        case let .authenticator(action):
            actionName += action.id
        }
        return actionName
    }
}
