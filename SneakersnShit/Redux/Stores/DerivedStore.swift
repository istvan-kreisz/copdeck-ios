//
//  DerivedStore.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/20/21.
//

import Foundation
import Combine

class DerivedStore<T: Equatable>: ObservableObject {
    let appStore: AppStore
    var effectCancellables: Set<AnyCancellable> = []
    private let derivedState: (AppState) -> T
    @Published var state: T
    @Published var globalState: GlobalState

    init(appStore: AppStore, derivedState: @escaping (AppState) -> T) {
        self.appStore = appStore
        self.state = derivedState(appStore.state)
        self.derivedState = derivedState
        self.globalState = appStore.state.globalState

        appStore.$state
            .compactMap { [weak self] in self?.derivedState($0) }
            .removeDuplicates()
            .sink { [weak self] state in
                self?.state = state
            }
            .store(in: &effectCancellables)

        appStore.$state
            .map(\.globalState)
            .removeDuplicates()
            .sink { [weak self] state in
                self?.globalState = state
            }
            .store(in: &effectCancellables)
    }

    func send(_ action: AppAction, debounceDelayMs: Int? = nil, completed: ((Result<Void, AppError>) -> Void)? = nil) {
        appStore.send(action, debounceDelayMs: debounceDelayMs, completed: completed)
    }
}

typealias SearchStore = DerivedStore<SearchState>
typealias FeedStore = DerivedStore<FeedState>

extension FeedStore {
    static func initWith(appStore: AppStore) -> FeedStore {
        FeedStore(appStore: appStore, derivedState: { $0.feedState })
    }

    static func initWith<T>(derivedStore: DerivedStore<T>) -> FeedStore {
        FeedStore.initWith(appStore: derivedStore.appStore)
    }
}

extension SearchStore {
    static func initWith(appStore: AppStore) -> SearchStore {
        SearchStore(appStore: appStore, derivedState: { $0.searchState })
    }

    static func initWith<T>(derivedStore: DerivedStore<T>) -> SearchStore {
        SearchStore.initWith(appStore: derivedStore.appStore)
    }
}
