//
//  AppAction.swift
//  CopDeck
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation

enum AppAction {
    case none
    case main(action: MainAction)
    case error(action: ErrorAction)
    case authentication(action: AuthenticationAction)
    case paymentAction(action: PaymentAction)
}

extension AppAction: Identifiable {
    var id: String {
        var actionName = "AppAction."
        switch self {
        case .none:
            actionName += "none"
        case let .main(action):
            actionName += action.id
        case let .error(action):
            actionName += action.label
        case let .authentication(action):
            actionName += action.label
        case let .paymentAction(action):
            actionName += action.label
        }
        return actionName
    }
}
