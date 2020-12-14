//
//  App.swift
//  InfluTrader
//
//  Created by István Kreisz on 12/13/20.
//

import Foundation
import Combine

enum CalendarAction {
    case action1
    case action2
}

enum TrendsAction {
    case action1
    case action2
}

enum AppAction {
    case calendar(action: CalendarAction)
    case trends(action: TrendsAction)
}

func trendsReducer(state: inout TrendsState,
                   action: TrendsAction,
                   environment: Trends) -> AnyPublisher<TrendsAction, Never> {
    switch action {
    case .action1:
        state = TrendsState()
    case .action2:
        return environment.service
            .publisher
            .replaceError(with: ())
            .map { TrendsAction.action1 }
            .eraseToAnyPublisher()
    }
    return Empty().eraseToAnyPublisher()
}

func calendarReducer(state: inout CalendarState,
                     action: CalendarAction,
                     environment: Calendar) -> AnyPublisher<CalendarAction, Never> {
    switch action {
    case .action1:
        state = CalendarState()
    case .action2:
        return environment.service
            .publisher
            .replaceError(with: ())
            .map { CalendarAction.action1 }
            .eraseToAnyPublisher()
    }
    return Empty().eraseToAnyPublisher()
}

func appReducer(state: inout AppState,
                action: AppAction,
                environment: World) -> AnyPublisher<AppAction, Never> {
    switch action {
    case let .calendar(action):
        return calendarReducer(state: &state.calendar, action: action, environment: environment.calendar)
            .map(AppAction.calendar)
            .eraseToAnyPublisher()
    case let .trends(action):
        return trendsReducer(state: &state.trends, action: action, environment: environment.trends)
            .map(AppAction.trends)
            .eraseToAnyPublisher()
    }
}

typealias AppStore = Store<AppState, AppAction, World>
