//
//  ErrorAction.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/7/21.
//

import Foundation

enum ErrorAction {
    case setError(error: AppError?)
}

extension ErrorAction: IdAble {
    var id: String {
        switch self {
        case .setError:
            return "setError"
        }
    }
}
