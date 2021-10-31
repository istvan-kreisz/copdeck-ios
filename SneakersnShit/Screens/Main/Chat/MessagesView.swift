////
////  MessagesView.swift
////  CopDeck
////
////  Created by István Kreisz on 10/31/21.
////
//
//import Foundation
//import SwiftUI
//import MessageKit
//import InputBarAccessoryView
//
//struct MessagesView: UIViewControllerRepresentable {
//    
//    @State var initialized = false
//    
//    let channel: Channel
//    let userId: String
//    let store: DerivedGlobalStore
//    
//    func makeUIViewController(context: Context) -> MessagesViewController {
//        let messagesVC = MessageViewController(channel: channel, userId: userId)
//        
//        messagesVC.messagesCollectionView.messagesDisplayDelegate = context.coordinator
//        messagesVC.messagesCollectionView.messagesLayoutDelegate = context.coordinator
//        messagesVC.messagesCollectionView.messagesDataSource = context.coordinator
//        messagesVC.messageInputBar.delegate = context.coordinator
//        messagesVC.scrollsToLastItemOnKeyboardBeginsEditing = true // default false
//        messagesVC.maintainPositionOnKeyboardFrameChanged = true // default false
//        messagesVC.showMessageTimestampOnSwipeLeft = true // default false
//        
//        return messagesVC
//    }
//    
//    func updateUIViewController(_ uiViewController: MessagesViewController, context: Context) {
//        uiViewController.messagesCollectionView.reloadData()
//        scrollToBottom(uiViewController)
//    }
//    
//    private func scrollToBottom(_ uiViewController: MessagesViewController) {
//        DispatchQueue.main.async {
//            // The initialized state variable allows us to start at the bottom with the initial messages without seeing the initial scroll flash by
//            uiViewController.messagesCollectionView.scrollToLastItem(animated: self.initialized)
//            self.initialized = true
//        }
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(messages: $messages)
//    }
//    
//    final class Coordinator {
//        let formatter: DateFormatter = {
//            let formatter = DateFormatter()
//            formatter.dateStyle = .medium
//            return formatter
//        }()
//        var messages: Binding<[Message]>
//        
//        init(messages: Binding<[Message]>) {
//            self.messages = messages
//        }
//    }
//}
//
//extension MessagesView.Coordinator: MessagesDataSource {
//    func currentSender() -> SenderType {
//        //
//        messages.wrappedValue.last?.sender
//    }
//    
//    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//        return messages.wrappedValue[indexPath.section]
//    }
//    
//    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
//        return messages.wrappedValue.count
//    }
//    
//    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        let name = message.sender.displayName
//        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
//    }
//    
//    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        let dateString = formatter.string(from: message.sentDate)
//        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
//    }
//
//    func messageTimestampLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        let sentDate = message.sentDate
//        let sentDateString = MessageKitDateFormatter.shared.string(from: sentDate)
//        let timeLabelFont: UIFont = .boldSystemFont(ofSize: 10)
//        let timeLabelColor: UIColor = .systemGray
//        return NSAttributedString(string: sentDateString, attributes: [NSAttributedString.Key.font: timeLabelFont, NSAttributedString.Key.foregroundColor: timeLabelColor])
//    }
//}
//
//@available(iOS 13.0, *)
//extension MessagesView.Coordinator: InputBarAccessoryViewDelegate {
//    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//        let message = MockMessage(text: text, user: SampleData.shared.currentSender, messageId: UUID().uuidString, date: Date())
//        messages.wrappedValue.append(message)
//        inputBar.inputTextView.text = ""
//    }
//}
//
//@available(iOS 13.0, *)
//extension MessagesView.Coordinator: MessagesLayoutDelegate, MessagesDisplayDelegate {
//    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//        let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
//        avatarView.set(avatar: avatar)
//    }
//    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 20
//    }
//    
//    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 16
//    }
//}
