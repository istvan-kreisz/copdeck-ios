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
    (inout State, Action, Environment, ((Result<Void, AppError>) -> Void)?) -> AnyPublisher<Action, Never>

final class ReduxStore<State, Action: IdAble, Environment>: ObservableObject {
    @Published private(set) var state: State

    let environment: Environment
    private let reducer: Reducer<State, Action, Environment>
    private var effectCancellables: Set<AnyCancellable> = []

    private var isRootStore: Bool {
        type(of: self) == ReduxStore<AppState, AppAction, World>.self
    }

    init(initialState: State,
         reducer: @escaping Reducer<State, Action, Environment>,
         environment: Environment) {
        state = initialState
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
            .sink(receiveCompletion: { [weak self] completion in
                if self?.isRootStore == true {
                    completed?(.success(()))
                }
            }, receiveValue: { [weak self] in
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
                                                                                reducer: { [weak self] _, action, _, completed in
                                                                                    self?.process(deriveAction(action), completed: completed)
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
