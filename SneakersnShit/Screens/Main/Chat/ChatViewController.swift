//
//  ChatViewController.swift
//  CopDeck
//
//  Created by István Kreisz on 10/31/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView

final class ChatViewController: MessagesViewController {
//    private var isSendingPhoto = false {
//        didSet {
//            messageInputBar.leftStackViewItems.forEach { item in
//                guard let item = item as? InputBarButtonItem else {
//                    return
//                }
//                item.isEnabled = !self.isSendingPhoto
//            }
//        }
//    }
    let userColor = UIColor.pillColors[0]
    let messageColors = Array(UIColor.pillColors.dropFirst())

    private let channel: Channel
    private let userId: String
    private let store: DerivedGlobalStore

    private var cancelListener: (() -> Void)?
    private var messages: [Message] = [] {
        didSet {
            #warning("only when other person texts")
            markAsSeen()
            #warning("add granular updates")
            messagesCollectionView.reloadData()
        }
    }
    private var user: User? {
        channel.users.first(where: { $0.id == userId })
    }
    
    func tearDown() {
        messages = []
        cancelListener?()
        markAsSeen()
    }
    
    init(channel: Channel, userId: String, store: DerivedGlobalStore) {
        self.channel = channel
        self.userId = userId
        self.store = store

        super.init(nibName: nil, bundle: nil)
        title = nil
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        markAsSeen()
        listenToMessages()
        setUpMessageView()
        removeMessageAvatars()
//        addCameraBarButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
        messagesCollectionView.scrollToLastItem(animated: true)
    }
    
    private func markAsSeen() {
        store.send(.main(action: .markChannelAsSeen(channel: channel)))
    }

    private func listenToMessages() {
        store.send(.main(action: .getChannelListener(channelId: channel.id, cancel: { [weak self] cancel in
            self?.cancelListener = cancel
        }, update: { [weak self] result in
            switch result {
            case let .success(messages):
                self?.messages = messages
                self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
            case let .failure(error):
                print(error)
            }
        })))
    }

    private func setUpMessageView() {
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        showMessageTimestampOnSwipeLeft = true
        messageInputBar.inputTextView.tintColor = .black
        messageInputBar.sendButton.setTitleColor(.black, for: .normal)

        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messagesCollectionView.contentInset.top = NavigationBar.size
    }

    private func removeMessageAvatars() {
        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {
            return
        }
        layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
        layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        layout.setMessageIncomingAvatarSize(.zero)
        layout.setMessageOutgoingAvatarSize(.zero)
        let incomingLabelAlignment = LabelAlignment(textAlignment: .left,
                                                    textInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
        layout.setMessageIncomingMessageTopLabelAlignment(incomingLabelAlignment)
        let outgoingLabelAlignment = LabelAlignment(textAlignment: .right,
                                                    textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15))
        layout.setMessageOutgoingMessageTopLabelAlignment(outgoingLabelAlignment)
    }

    // MARK: - Helpers

    private func sendMessage(content: String) {
        store.send(.main(action: .sendChatMessage(message: content, channelId: channel.id, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                #warning("show error message")
                print(error)
            case .success(()):
                break
            }
        })))
    }

//    private func insertNewMessage(_ message: Message) {
//        if messages.contains(message) {
//            return
//        }
//
//        messages.append(message)
//        messages.sort()
//
//        let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
//        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
//
//        messagesCollectionView.reloadData()
//
//        if shouldScrollToBottom {
//            messagesCollectionView.scrollToLastItem(animated: true)
//        }
//    }

//    private func handleDocumentChange(_ change: DocumentChange) {
//        guard var message = Message(document: change.document) else {
//            return
//        }
//
//        switch change.type {
//        case .added:
//            if let url = message.downloadURL {
//                downloadImage(at: url) { [weak self] image in
//                    guard
//                        let self = self,
//                        let image = image
//                    else {
//                        return
//                    }
//                    message.image = image
//                    self.insertNewMessage(message)
//                }
//            } else {
//                insertNewMessage(message)
//            }
//        default:
//            break
//        }
//    }
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.senderId == userId {
            return userColor
        } else {
            return .white
        }
    }

    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        false
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        #warning("finish")
//        avatarView.set(avatar: .init(image: "", initials: "?"))
        avatarView.isHidden = true
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let color: UIColor
        if message.sender.senderId == userId {
            color = userColor
        } else {
            if let index = channel.userIds.filter({ $0 != userId }).sorted().firstIndex(of: message.sender.senderId) {
                color =  messageColors[index % messageColors.count]
            } else {
                color =  messageColors.randomElement()!
            }
        }
        
        return .bubbleOutline(color)
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        0
    }
    
    func typingIndicatorViewSize(for layout: MessagesCollectionViewFlowLayout) -> CGSize {
        .zero
    }
}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }

    func currentSender() -> SenderType {
        user.map { Sender(user: $0) } ?? Sender(id: userId, name: "Anonymus")
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        NSAttributedString(string: message.sender.displayName,
                           attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1), .foregroundColor: UIColor(white: 0.3, alpha: 1)])
    }
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        sendMessage(content: text)
        inputBar.inputTextView.text = ""
    }
}

// MARK: - UIImagePickerControllerDelegate

// extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    private func addCameraBarButton() {
//        let cameraItem = InputBarButtonItem(type: .system)
//        cameraItem.tintColor = .primary
//        cameraItem.image = UIImage(named: "camera")
//        cameraItem.addTarget(self,
//                             action: #selector(cameraButtonPressed),
//                             for: .primaryActionTriggered)
//        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
//
//        messageInputBar.leftStackView.alignment = .center
//        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
//        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
//    }

    // MARK: - Actions

//    @objc private func cameraButtonPressed() {
//        let picker = UIImagePickerController()
//        picker.delegate = self
//
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            picker.sourceType = .camera
//        } else {
//            picker.sourceType = .photoLibrary
//        }
//
//        present(picker, animated: true)
//    }

//    private func uploadImage(_ image: UIImage,
//                             to channel: Channel,
//                             completion: @escaping (URL?) -> Void) {
//        guard
//            let channelId = channel.id,
//            let scaledImage = image.scaledToSafeUploadSize,
//            let data = scaledImage.jpegData(compressionQuality: 0.4)
//        else {
//            return completion(nil)
//        }
//
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpeg"
//
//        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
//        let imageReference = storage.child("\(channelId)/\(imageName)")
//        imageReference.putData(data, metadata: metadata) { _, _ in
//            imageReference.downloadURL { url, _ in
//                completion(url)
//            }
//        }
//    }

//    private func sendPhoto(_ image: UIImage) {
//        isSendingPhoto = true
//
//        uploadImage(image, to: channel) { [weak self] url in
//            guard let self = self else { return }
//            self.isSendingPhoto = false
//
//            guard let url = url else {
//                return
//            }
//
//            var message = Message(user: self.user, image: image)
//            message.downloadURL = url
//
//            self.save(message)
//            self.messagesCollectionView.scrollToLastItem()
//        }
//    }

//    private func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
//        let ref = Storage.storage().reference(forURL: url.absoluteString)
//        let megaByte = Int64(1 * 1024 * 1024)
//
//        ref.getData(maxSize: megaByte) { data, _ in
//            guard let imageData = data else {
//                completion(nil)
//                return
//            }
//            completion(UIImage(data: imageData))
//        }
//    }

//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//        picker.dismiss(animated: true)
//
//        if let asset = info[.phAsset] as? PHAsset {
//            let size = CGSize(width: 500, height: 500)
//            PHImageManager.default().requestImage(for: asset,
//                                                  targetSize: size,
//                                                  contentMode: .aspectFit,
//                                                  options: nil) { result, _ in
//                guard let image = result else {
//                    return
//                }
//                self.sendPhoto(image)
//            }
//        } else if let image = info[.originalImage] as? UIImage {
//            sendPhoto(image)
//        }
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true)
//    }
// }
