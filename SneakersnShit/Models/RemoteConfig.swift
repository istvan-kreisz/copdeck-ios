//
//  RemoteConfig.swift
//  CopDeck
//
//  Created by István Kreisz on 12/21/21.
//

import Foundation

struct RemoteConfig: Codable, Equatable {
    let paywallEnabled: Bool
    let spreadsheetImportNotice: String
    let lifetimePriceCheckLimit: Int
    let stacksLimit: Int
    let showPaywallOnLaunch: Bool
    let algoliaKey: String
}
