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
    let userColor = UIColor.messageColors[0]
    let messageColors = Array(UIColor.messageColors.dropFirst())

    private let channel: Channel
    private let userId: String
    private let store: DerivedGlobalStore

    private var cancelListener: (() -> Void)?
    private var messages: [Message] = []

    private var images: [String: UIImage] = [:] {
        didSet {
            messagesCollectionView.reloadData()
        }
    }

    private var user: User? {
        channel.users.first(where: { $0.id == userId })
    }

    func tearDown() {
        messages = []
        messagesCollectionView.reloadData()
        cancelListener?()
        markAsSeen()
    }

    init(channel: Channel, userId: String, store: DerivedGlobalStore) {
        self.channel = channel
        self.userId = userId
        self.store = store

        super.init(nibName: nil, bundle: nil)
        title = nil
        downloadProfileImages()
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
//        addCameraBarButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    private func downloadProfileImages() {
        channel.users.forEach { user in
            if let url = user.imageURL {
                UIImage.download(from: url) { [weak self] image in
                    if let image = image {
                        self?.images[user.id] = image
                    }
                }
            }
        }
    }

    private func markAsSeen() {
        store.send(.main(action: .markChannelAsSeen(channel: channel)))
    }

    private func listenToMessages() {
        store.send(.main(action: .getChannelListener(channelId: channel.id, cancel: { [weak self] cancel in
            self?.cancelListener = cancel
        }, update: { [weak self] result in
            DispatchQueue.main.async {
                self?.updateCollectionView(result: result)
            }
        })))
    }

    private func updateCollectionView(result: Result<([Change<Message>], [Message]), AppError>) {
        switch result {
        case let .success((changes, newValue)):
            let updatedMessagesSorted = newValue.sortedByDate()
            var added: [Message] = []
            var updated: [Message] = []
            var deleted: [Message] = []

            if messages.isEmpty {
                messages = updatedMessagesSorted
                messagesCollectionView.reloadData()
                DispatchQueue.main.async {
                    self.messagesCollectionView.scrollToLastItem(animated: true)
                }
            } else {
                var hasChangesFromOthers = false

                changes.forEach { change in
                    let m: Message
                    switch change {
                    case let .add(message):
                        m = message
                        added.append(message)
                    case let .update(message):
                        m = message
                        updated.append(message)
                    case let .delete(message):
                        m = message
                        deleted.append(message)
                    }
                    if !hasChangesFromOthers, m.sender.senderId != self.userId {
                        hasChangesFromOthers = true
                    }
                }
                let deletedIndexes = deleted.compactMap { (message: Message) -> Int? in
                    messages.firstIndex(where: { $0.id == message.id })
                }
                let updatedIndexes = updated.compactMap { (message: Message) -> Int? in
                    messages.firstIndex(where: { $0.id == message.id })
                }
                let addedIndexes = added.sortedByDate().enumerated().map { (index: Int, _) -> Int in
                    messages.count + index - deletedIndexes.count
                }

                messages = updatedMessagesSorted

                messagesCollectionView.performBatchUpdates { [weak self] in
                    guard let self = self else { return }
                    if !addedIndexes.isEmpty {
                        self.messagesCollectionView.insertSections(.init(addedIndexes))
                    }
                    if !updatedIndexes.isEmpty {
                        self.messagesCollectionView.reloadSections(.init(updatedIndexes))
                    }
                    if !deletedIndexes.isEmpty {
                        self.messagesCollectionView.deleteSections(.init(deletedIndexes))
                    }
                } completion: { [weak self] _ in
                    guard let self = self else { return }
                    if self.isLastSectionVisible() {
                        self.messagesCollectionView.scrollToLastItem(animated: true)
                    }
                    if hasChangesFromOthers {
                        self.markAsSeen()
                    }
                }
            }
        case let .failure(error):
            showAlert(title: "Failed to load messsages", message: error.localizedDescription)
        }
    }

    private func showAlert(title: String, message: String) {
        Debouncer.debounce(delay: .seconds(3), id: "showChatAlert") { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default))
            self?.present(alert, animated: true, completion: nil)
        } cancel: {}
    }

    private func isLastSectionVisible() -> Bool {
        guard !messages.isEmpty else { return false }

        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }

    private func setUpMessageView() {
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        showMessageTimestampOnSwipeLeft = true

        messageInputBar.sendButton.titleLabel?.font = .bold(size: 19)
        messageInputBar.sendButton.setTitleColor(UIColor(.customBlue), for: .normal)
        messageInputBar.sendButton.setTitleColor(UIColor(.customBlue), for: .highlighted)
        messageInputBar.sendButton.setTitleColor(UIColor(.customBlue), for: .focused)
        messageInputBar.sendButton.tintColor = UIColor(.customBlue)

        messageInputBar.inputTextView.tintColor = UIColor(.customText1)
        messageInputBar.inputTextView.font = .medium(size: 17)
        messageInputBar.inputTextView.textColor = UIColor(.customText1)
        messageInputBar.inputTextView.placeholderTextColor = UIColor(.customText2)

        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self

        messagesCollectionView.contentInset.top = NavigationBar.size
        additionalBottomInset = 3

        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
            layout.setMessageOutgoingCellBottomLabelAlignment(.init(textAlignment: .right, textInsets: .zero))
            layout.setMessageOutgoingAvatarSize(.zero)
            layout
                .setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right,
                                                                           textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)))
            layout
                .setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right,
                                                                              textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)))
        }
    }

    // MARK: - Helpers

    private func sendMessage(content: String) {
        store.send(.main(action: .sendChatMessage(message: content, channelId: channel.id, completion: { [weak self] result in
            switch result {
            case let .failure(error):
                self?.showAlert(title: "Failed to send message", message: error.localizedDescription)
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
        color(for: message)
    }

    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        false
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let sender = messages[safe: indexPath.section]?.sender else { return }
        avatarView.isHidden = isNextMessageSameSender(at: indexPath)

        avatarView.set(avatar: .init(image: images[sender.senderId], initials: "?"))
        avatarView.layer.borderWidth = 2
        avatarView.layer.borderColor = color(for: message).cgColor
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        .bubble
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        nil
    }

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        0
    }

    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        UIColor(.customWhite)
    }

    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        [NSAttributedString.Key.foregroundColor: UIColor.white,
         NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
         NSAttributedString.Key.underlineColor: UIColor.white]
    }

    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .phoneNumber, .date, .mention, .hashtag]
    }

    private func color(for message: MessageType) -> UIColor {
        if message.sender.senderId == userId {
            return userColor
        } else {
            if let index = channel.userIds.filter({ $0 != userId }).sorted().firstIndex(of: message.sender.senderId) {
                return messageColors[index % messageColors.count]
            } else {
                return messageColors.randomElement()!
            }
        }
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        isFromNewSender(message: message, at: indexPath) ? 20 : 0
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        0
    }

    func typingIndicatorViewSize(for layout: MessagesCollectionViewFlowLayout) -> CGSize {
        .zero
    }
}

extension ChatViewController: MessageCellDelegate {
    func didSelectDate(_ date: Date) {
        if let url = URL(string: "calshow:\(date.timeIntervalSinceReferenceDate)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    func didSelectPhoneNumber(_ phoneNumber: String) {
        if let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    func didSelectURL(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
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
        messages[safe: indexPath.section] ?? Message(user: user ?? User(id: userId), content: "")
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let username = NSAttributedString(string: message.sender.displayName,
                                          attributes: [.font: UIFont.regular(size: 14), .foregroundColor: UIColor(.customText1)])
        return isFromNewSender(message: message, at: indexPath) ? username : nil
    }

    private func isFromNewSender(message: MessageType, at indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {
            if let previousMessage = messages[safe: indexPath.section - 1] {
                if previousMessage.sender.senderId == message.sender.senderId {
                    return false
                } else {
                    return true
                }
            } else {
                return true
            }
        }
    }

    private func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messages.count else { return false }
        return messages[safe: indexPath.section]?.sender.senderId == messages[safe: indexPath.section + 1]?.sender.senderId
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
