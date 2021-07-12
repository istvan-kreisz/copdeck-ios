//
//  ReduxStore.swift
//  SneakersnShit
//
//  Created by István Kreisz on 12/13/20.
//

import Foundation

import Foundation
import Combine

typealias Reducer<State, Action, Environment> =
    (inout State, Action, Environment) -> AnyPublisher<Action, Never>

final class ReduxStore<State, Action: IdAble, Environment>: ObservableObject {
    @Published private(set) var state: State

    let environment: Environment
    private let reducer: Reducer<State, Action, Environment>
    private var effectCancellables: Set<AnyCancellable> = []

    init(initialState: State,
         reducer: @escaping Reducer<State, Action, Environment>,
         environment: Environment) {
        state = initialState
        self.reducer = reducer
        self.environment = environment
    }

    @discardableResult func send(_ action: Action) -> Future<Void, AppError> {
        Future<Void, AppError> { promise in
            Debouncer.debounce(delay: .milliseconds(500), id: action.id) { [weak self] in
                self?.process(action, completed: promise)
            } cancel: {
                promise(.success(()))
            }
        }
    }

    private func process(_ action: Action, completed: @escaping (Result<Void, AppError>) -> Void) {
        var callCompleted = true
        reducer(&state, action, environment)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                guard callCompleted else { return }
                completed(.success(()))
            }, receiveValue: { [weak self] in
                callCompleted = false
                self?.process($0, completed: completed)
            })
            .store(in: &effectCancellables)
    }

    private var derivedCancellable: AnyCancellable?

    func derived<DerivedState: Equatable, DerivedAction, DerivedEnvironment>(deriveState: @escaping (State) -> DerivedState,
                                                                             deriveAction: @escaping (DerivedAction) -> Action,
                                                                             derivedEnvironment: DerivedEnvironment)
        -> ReduxStore<DerivedState, DerivedAction, DerivedEnvironment> {
        let store = ReduxStore<DerivedState, DerivedAction, DerivedEnvironment>(initialState: deriveState(state),
                                                                                reducer: { [weak self] _, action, _ in
                                                                                    self?.process(deriveAction(action), completed: { _ in })
                                                                                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                                                                                },
                                                                                environment: derivedEnvironment)

        store.derivedCancellable = $state
            .map(deriveState)
            .removeDuplicates()
            .sink { [weak store] in store?.state = $0 }

        return store
    }
}
