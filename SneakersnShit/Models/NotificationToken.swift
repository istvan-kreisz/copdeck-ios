//
//  NotificationToken.swift
//  CopDeck
//
//  Created by István Kreisz on 11/3/21.
//

import Foundation

struct NotificationToken: Equatable, Codable {
    let token: String
    let userId: String
    let deviceId: String
    var refreshedDate: Double
    var created: Double = Date.serverDate
    var updated: Double = Date.serverDate
}
