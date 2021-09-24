//
//  DerivedStore.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/20/21.
//

import Foundation
import Combine

class DerivedGlobalStore: ObservableObject {
    let appStore: AppStore
    var effectCancellables: Set<AnyCancellable> = []
    @Published var globalState: GlobalState

    init(appStore: AppStore) {
        self.appStore = appStore
        self.globalState = appStore.state.globalState

        appStore.stateSubject
            .map(\.globalState)
            .sink { [weak self] state in
                self?.globalState = state
            }
            .store(in: &effectCancellables)
    }

    func send(_ action: AppAction, debounceDelayMs: Int? = nil, completed: ((Result<Void, AppError>) -> Void)? = nil) {
        appStore.send(action, debounceDelayMs: debounceDelayMs, completed: completed)
    }
}

class DerivedStore<T: Equatable>: DerivedGlobalStore {
    @Published var state: T
    let derivedState: (AppState) -> T

    init(appStore: AppStore, derivedState: @escaping (AppState) -> T) {
        self.state = derivedState(appStore.state)
        self.derivedState = derivedState
        super.init(appStore: appStore)

        appStore.stateSubject
            .compactMap { [weak self] in self?.derivedState($0) }
            .sink { [weak self] state in
                self?.state = state
            }
            .store(in: &effectCancellables)
    }
}

typealias SearchStore = DerivedStore<SearchState>
typealias FeedStore = DerivedStore<FeedState>

extension DerivedGlobalStore {
    static let `default`: DerivedGlobalStore = DerivedGlobalStore(appStore: AppStore.default)
}

extension FeedStore {
    static let `default`: FeedStore = FeedStore(appStore: AppStore.default, derivedState: { $0.feedState })
}

extension SearchStore {
    static let `default`: SearchStore = SearchStore(appStore: AppStore.default, derivedState: { $0.searchState })
}
