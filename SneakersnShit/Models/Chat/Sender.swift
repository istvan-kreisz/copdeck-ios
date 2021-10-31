//
//  Sender.swift
//  CopDeck
//
//  Created by István Kreisz on 10/30/21.
//

import SwiftUI
import MessageKit

struct Sender: Codable, SenderType {
    let id: String
    let name: String
    
    var senderId: String { id }
    var displayName: String { name }
}

extension Sender {
    init(user: User) {
        self.id = user.id
        self.name = user.name ?? "Anonymus"
    }
}
