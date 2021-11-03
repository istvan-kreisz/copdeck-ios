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
    let refreshedDate: Double
}
