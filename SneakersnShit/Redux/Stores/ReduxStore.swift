//
//  ReduxStore.swift
//  CopDeck
//
//  Created by István Kreisz on 12/13/20.
//

import Foundation

import Foundation
import Combine

typealias Reducer<State, Action, Environment> =
    (inout State, Action, Environment, ((Result<Void, AppError>) -> Void)?) -> AnyPublisher<Action, Never>

final class ReduxStore<State, Action: IdAble, Environment>: ObservableObject {
    @Published private(set) var state: State

    let environment: Environment
    private let reducer: Reducer<State, Action, Environment>
    private var effectCancellables: Set<AnyCancellable> = []

    init(state: State, reducer: @escaping Reducer<State, Action, Environment>, environment: Environment) {
        self.state = state
        self.reducer = reducer
        self.environment = environment
    }

    func send(_ action: Action, completed: ((Result<Void, AppError>) -> Void)? = nil) {
        Debouncer.debounce(delay: .milliseconds(500), id: action.id) { [weak self] in
            self?.process(action, completed: completed)
        } cancel: {
            completed?(.success(()))
        }
    }

    private func process(_ action: Action, completed: ((Result<Void, AppError>) -> Void)?) {
        reducer(&state, action, environment, completed)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                completed?(.success(()))
            }, receiveValue: { [weak self] in
                self?.process($0, completed: completed)
            })
            .store(in: &effectCancellables)
    }
}
