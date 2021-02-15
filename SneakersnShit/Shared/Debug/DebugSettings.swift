//
//  DebugSettings.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/29/21.
//

import Foundation

struct DebugSettings {
    private init() {}

    static let shared = DebugSettings()

    var useMockData: Bool {
        guard let value = ProcessInfo.processInfo.environment["useMockData"] else { return false }
        return Bool(value) ?? false
    }
}
