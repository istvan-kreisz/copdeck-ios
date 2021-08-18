//
//  DebugSettings.swift
//  CopDeck
//
//  Created by István Kreisz on 1/29/21.
//

import Foundation

func log(_ value: Any) {
    if DebugSettings.shared.isInDebugMode {
        print("------------------")
        print(value)
    }
}

struct DebugSettings {
    let isInDebugMode: Bool

    private init() {
        #if DEBUG
            isInDebugMode = true
        #else
            isInDebugMode = false
        #endif
    }

    static let shared = DebugSettings()

    func bool(for key: String) -> Bool {
        guard let value = ProcessInfo.processInfo.environment[key] else { return false }
        return Bool(value) ?? false
    }

    func double(for key: String) -> Double? {
        guard let value = ProcessInfo.processInfo.environment[key] else { return nil }
        return Double(value)
    }

    var useMockData: Bool {
        bool(for: "useMockData")
    }

    var useFunctionsEmulator: Bool {
        bool(for: "useFunctionsEmulator")
    }

    var showScraperLogs: Bool {
        bool(for: "showScraperLogs")
    }
}
