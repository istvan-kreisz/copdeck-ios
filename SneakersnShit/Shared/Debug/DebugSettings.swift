//
//  DebugSettings.swift
//  CopDeck
//
//  Created by István Kreisz on 1/29/21.
//

import Foundation

enum AppEnvironment: String {
    case debugStaging = "Debug Staging"
    case releaseStaging = "Release Staging"

    case debugProduction = "Debug"
    case releaseProduction = "Release"
}

enum LogType {
    case reduxAction, database, cache, scraping, error
}

func log(_ value: Any, logType: LogType? = nil) {
    guard DebugSettings.shared.isInDebugMode else { return }
    var shouldPrint = false
    switch logType {
    case .reduxAction:
        shouldPrint = DebugSettings.shared.showReduxLogs
    case .database:
        shouldPrint = DebugSettings.shared.showDatabaseLogs
    case .cache:
        shouldPrint = DebugSettings.shared.showCacheLogs
    case .scraping:
        shouldPrint = DebugSettings.shared.showScrapingLogs
    case .error:
        shouldPrint = DebugSettings.shared.showErrorLogs
    case .none:
        shouldPrint = true
    }
    if shouldPrint {
        print("------------------")
        print(value)
    }
}

struct DebugSettings {
    let isInDebugMode: Bool

    let istvanId = "s80wQjTNqXRlRzirFlgY3MF9BxJ3"
    let milanId = "U5VMyc8UNsN1JvDlWYOxQUmL6uE2"

    var isIstvan: Bool { DefaultAuthenticator.user?.uid == istvanId }
    var isMilan: Bool { DefaultAuthenticator.user?.uid == milanId }
    var isTester: Bool { DefaultAuthenticator.user?.email.map(isTesterEmail) == true }

    private func isTesterEmail(_ email: String) -> Bool {
        let regex1 = "milan\\+[0-9]+@copdeck.com"
        let regex2 = "istvan\\+[0-9]+@copdeck.com"

        let predicate1 = NSPredicate(format: "SELF MATCHES %@", regex1)
        let predicate2 = NSPredicate(format: "SELF MATCHES %@", regex2)
        return predicate1.evaluate(with: email) || predicate2.evaluate(with: email)
    }

    lazy var environment: AppEnvironment? = {
        guard let currentConfiguration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String,
              let environment = AppEnvironment(rawValue: currentConfiguration)
        else { return nil }
        return environment
    }()

    func adminName(for userId: String) -> String? {
        switch userId {
        case milanId:
            return "Milan"
        case istvanId:
            return "Istvan"
        default:
            return nil
        }
    }

    var isAdmin: Bool {
        isIstvan || isMilan
    }

    var isSuperAdmin: Bool {
        isIstvan || isMilan
    }

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
        guard isInDebugMode else { return nil }
        return ProcessInfo.processInfo.environment[key]
    }

    private func bool(for key: String) -> Bool {
        guard let value = string(for: key) else { return false }
        return Bool(value) ?? false
    }

    func double(for key: String) -> Double? {
        guard let value = string(for: key) else { return nil }
        return Double(value)
    }
    
    var loginAs: String? {
        string(for: "loginAs")
    }

    #warning("replace with localhost")
    var ipAddress: String {
        string(for: "ipAddress") ?? ""
    }

    var useFunctionsEmulator: Bool {
        bool(for: "useFunctionsEmulator")
    }

    var useFirestoreEmulator: Bool {
        bool(for: "useFirestoreEmulator")
    }

    var showScraperLogs: Bool {
        bool(for: "showScraperLogs")
    }

    var showDatabaseLogs: Bool {
        bool(for: "showDatabaseLogs")
    }

    var showCacheLogs: Bool {
        bool(for: "showCacheLogs")
    }

    var showReduxLogs: Bool {
        bool(for: "showReduxLogs")
    }

    var showScrapingLogs: Bool {
        bool(for: "showScrapingLogs")
    }

    var showErrorLogs: Bool {
        bool(for: "showErrorLogs")
    }

    var clearUserDefaults: Bool {
        bool(for: "clearUserDefaults")
    }

    var blockImageDownload: Bool {
        bool(for: "blockImageDownload")
    }
}
