//
//  SettingsAction.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation

enum SettingsAction {
    case action1
    case action2
}

extension SettingsAction: IdAble {
    var id: String {
        switch self {
        case .action1:
            return "action1"
        case .action2:
            return "action2"
        }
    }
}
