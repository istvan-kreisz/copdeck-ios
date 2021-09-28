//
//  AppError.swift
//  CopDeck
//
//  Created by István Kreisz on 2/1/21.
//

import Foundation

struct AppError: Identifiable, LocalizedError, Equatable {
    let id = UUID().uuidString
    let title: String
    let message: String
    let error: Error?

    init(title: String = "Ooops", message: String = "Unknown Error", error: Error? = nil) {
        self.title = title
        self.message = message
        self.error = error
    }
    
    var errorDescription: String? {
        message
    }    
}

extension AppError {
    init(error: Error) {
        self.init(title: "Error", message: error.localizedDescription, error: error)
    }

    static var unknown: Self = .init(title: "", message: "")
    static var unauthenticated: Self = .init(title: "Error", message: "Not Authenticated")

    static func == (_ lhs: AppError, _ rhs: AppError) -> Bool {
        lhs.id == rhs.id
    }
}
