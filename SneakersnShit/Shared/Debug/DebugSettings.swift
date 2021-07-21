//
//  DebugSettings.swift
//  CopDeck
//
//  Created by István Kreisz on 1/29/21.
//

import Foundation

struct DebugSettings {
    private init() {}

    static let shared = DebugSettings()

    private func bool(for key: String) -> Bool {
        guard let value = ProcessInfo.processInfo.environment[key] else { return false }
        return Bool(value) ?? false
    }

    var useMockData: Bool {
        bool(for: "useMockData")
    }

    var useFunctionsEmulator: Bool {
        bool(for: "useFunctionsEmulator")
    }
}
