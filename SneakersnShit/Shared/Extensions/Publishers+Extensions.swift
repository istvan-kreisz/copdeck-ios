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

extension AnyPublisher where Failure == AppError {
    func complete(completion: @escaping (Result<Output, AppError>) -> Void) -> AnyPublisher<AppAction, Never> {
        prefix(1)
            .handleEvents(receiveOutput: { items in
                completion(.success(items))
            }, receiveCompletion: { result in
                guard case let .failure(error) = result else { return }
                completion(.failure(error))
            })
            .map { _ in AppAction.none }
            .replaceError(with: AppAction.none)
            .eraseToAnyPublisher()
    }
}
