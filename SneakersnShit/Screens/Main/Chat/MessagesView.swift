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
