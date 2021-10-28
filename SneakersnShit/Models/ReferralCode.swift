//
//  ReferralCode.swift
//  CopDeck
//
//  Created by István Kreisz on 10/16/21.
//

import Foundation

struct ReferralCode: Codable, Equatable, Identifiable {
    let code: String
    let discount: String
    let ownerId: String?
    let name: String?
    let expireDate: Double?
    let isValid: Bool?
    let signedUp: [String]?
    let subscribed: [String]?
    
    var id: String { code }
}
