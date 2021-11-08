//
//  ViewWithAlert.swift
//  CopDeck
//
//  Created by István Kreisz on 11/8/21.
//

import SwiftUI

protocol ViewWithAlert: View {
    var alert: State<(String, String)?> { get }
}

extension ViewWithAlert {
    func showError(_ appError: AppError) {
        self.alert.wrappedValue = (appError.title, appError.message)
    }
    
    func handleResult<T>(result: Result<T, AppError>, loader: ((Result<Void, AppError>) -> Void)?, completion: (T) -> Void) {
        switch result {
        case let .success(results):
            completion(results)
        case let .failure(error):
            showError(error)
        }
        loader?(.success(()))
    }
}
