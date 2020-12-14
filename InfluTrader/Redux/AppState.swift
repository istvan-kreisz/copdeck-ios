//
//  AppState.swift
//  InfluTrader
//
//  Created by István Kreisz on 12/13/20.
//

import Foundation

struct CalendarState: Equatable {}

struct TrendsState: Equatable {}

struct SettingState: Equatable {}

struct AppState: Equatable {
    var calendar = CalendarState()
    var trends = TrendsState()
    var settings = SettingState()
}
