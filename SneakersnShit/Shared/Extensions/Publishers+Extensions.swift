//
//  Publishers+Extensions.swift
//  CopDeck
//
//  Created by István Kreisz on 3/30/21.
//

import Combine

extension Publishers.Map where Output == AppAction {
    func catchErrors()
        -> AnyPublisher<Publishers.ReplaceError<Publishers.TryCatch<Publishers.Map<Upstream, AppAction>, Just<AppAction>>>.Output,
            Publishers.ReplaceError<Publishers.TryCatch<Publishers.Map<Upstream, AppAction>, Just<AppAction>>>.Failure> {
        tryCatch { Just(AppAction.error(action: .setError(error: AppError(error: $0)))) }
            .replaceError(with: AppAction.error(action: .setError(error: AppError.unknown)))
            .eraseToAnyPublisher()
    }
}
