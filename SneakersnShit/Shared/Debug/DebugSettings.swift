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

    struct Credentials {
        let username: String
        let password: String
    }

    var loginCredentials: Credentials? {
        guard isInDebugMode else { return nil }
        if let username = string(for: "username"), let password = string(for: "password") {
            return .init(username: username, password: password)
        } else {
            return nil
        }
    }

    func string(for key: String) -> String? {
        ProcessInfo.processInfo.environment[key]
    }

    func bool(for key: String) -> Bool {
        guard let value = string(for: key) else { return false }
        return Bool(value) ?? false
    }

    func double(for key: String) -> Double? {
        guard let value = string(for: key) else { return nil }
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
