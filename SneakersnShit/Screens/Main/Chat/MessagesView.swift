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

struct MessagesView: View {
    @Environment(\.presentationMode) var presentationMode

    let channel: Channel
    let userId: String
    let store: DerivedGlobalStore

    var chatName: String {
        channel.users.filter { $0.id != userId }.map { $0.name ?? "Anonymus" }.joined(separator: " & ")
    }

    var body: some View {
        ZStack {
            ChatDetailView(channel: channel, userId: userId, store: store)
                .withDefaultPadding(padding: .top)
                .withSafeAreaTopPadding()

            Rectangle().fill(Color.white)
                .frame(width: UIScreen.screenWidth, height: NavigationBar.size + UIApplication.shared.safeAreaInsets().top)
                .topAligned()
            NavigationBar(title: chatName, isBackButtonVisible: true, titleFontSize: .large, style: .dark) {
                presentationMode.wrappedValue.dismiss()
            }
            .withDefaultPadding(padding: [.horizontal])
            .withSafeAreaTopPadding()
            .topAligned()
        }
        .edgesIgnoringSafeArea(.vertical)
    }
}

struct ChatDetailView: UIViewControllerRepresentable {
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
