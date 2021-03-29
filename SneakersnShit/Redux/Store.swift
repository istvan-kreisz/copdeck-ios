//
//  Store.swift
//  SneakersnShit
//
//  Created by István Kreisz on 12/13/20.
//

import Foundation

import Foundation
import Combine

typealias Reducer<State, Action, Environment> =
    (inout State, Action, Environment) -> AnyPublisher<Action, Never>?

final class Store<State, Action: IdAble, Environment>: ObservableObject {
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

    func send(_ action: Action) {
        Throttler.throttle(delay: .milliseconds(200), id: action.id) { [weak self] in
            guard let self = self, let effect = self.reducer(&self.state, action, self.environment) else {
                return
            }

            effect
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: self.send)
                .store(in: &self.effectCancellables)
        }
    }

    private var derivedCancellable: AnyCancellable?

    func derived<DerivedState: Equatable, DerivedAction, DerivedEnvironment>(deriveState: @escaping (State) -> DerivedState,
                                                                             deriveAction: @escaping (DerivedAction) -> Action,
                                                                             derivedEnvironment: DerivedEnvironment)
        -> Store<DerivedState, DerivedAction, DerivedEnvironment> {
        let store = Store<DerivedState, DerivedAction, DerivedEnvironment>(initialState: deriveState(state),
                                                                           reducer: { _, action, _ in
                                                                               self.send(deriveAction(action))
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
