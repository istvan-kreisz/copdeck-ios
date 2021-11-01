//
//  MessagesView.swift
//  CopDeck
//
//  Created by István Kreisz on 10/31/21.
//

import Foundation
import SwiftUI
import MessageKit
import InputBarAccessoryView

//struct MessagesView: View {
//    static let profileImageSize: CGFloat = 58
//    
//    let channel: Channel
//    let userId: String
//    let didTapChannel: () -> Void
//    let didTapUser: () -> Void
//    
//    var lastMessageContent: String {
//        if let lastMessage = channel.lastMessage {
//            if lastMessage.userId == userId {
//                return "Me: \(lastMessage.content)"
//            } else {
//                return "\(channel.messagePartner(userId: userId)?.name ?? "Anonymus"): \(lastMessage.content)"
//            }
//        } else {
//            return ""
//        }
//    }
//    
//    var body: some View {
//        if let messagePartner = channel.messagePartner(userId: userId) {
//            HStack(alignment: .center, spacing: 10) {
//            }
//        }
//    }
//}

struct MessagesView: UIViewControllerRepresentable {
    let channel: Channel
    let userId: String
    let store: DerivedGlobalStore

    static func dismantleUIViewController(_ uiViewController: ChatViewController, coordinator: ()) {
        uiViewController.tearDown()
    }
    
    func makeUIViewController(context: Context) -> ChatViewController {
        ChatViewController(channel: channel, userId: userId, store: store)
    }

    func updateUIViewController(_ uiViewController: ChatViewController, context: Context) {}
}
