//
//  ChatService.swift
//  CopDeck
//
//  Created by István Kreisz on 11/4/21.
//

import Firebase
import Combine
import UIKit


class ChatWorker: FirestoreServiceWorker, ChatManager {
    weak var delegate: FirestoreWorkerDelegate!
    let errorsSubject = PassthroughSubject<AppError, Never>()
    
    var cancellables: Set<AnyCancellable> = []

    private let channelCache = Cache<String, Channel>(entryLifetimeMin: 60)

    // collection listeners
    private var channelsListener = CollectionListener<Channel>()
    private var channelListener = CollectionListener<Message>()

    // document listeners
    private var chatUpdatesListener = DocumentListener<ChatUpdateInfo>()

    var dbListeners: [FireStoreListener] {
        let listeners: [FireStoreListener?] = [channelsListener, channelListener, chatUpdatesListener]
        return listeners.compactMap { $0 }
    }

    // document publishers
    var chatUpdatesPublisher: AnyPublisher<ChatUpdateInfo, AppError> {
        chatUpdatesListener.dataPublisher.compactMap { $0 }.eraseToAnyPublisher()
    }
    
    required init(delegate: FirestoreWorkerDelegate) {
        self.delegate = delegate
    }

    func listenToChanges(userId: String) {
        chatUpdatesListener.startListening(documentRef: firestore.collection("chatUpdates").document(userId))
    }

    func getChannelsListener(cancel: @escaping (_ cancel: @escaping () -> Void) -> Void, update: @escaping (Result<[Channel], AppError>) -> Void) {
        guard let userId = userId else { return }

        channelsListener.reset(reinitializePublishers: true)
        channelsListener.startListening(collectionName: "channels", firestore: firestore) {
            $0?
                .whereField("userIds", arrayContains: userId)
                .whereField("lastMessageSentDate", isNotEqualTo: 0)
        }

        let publisher = channelsListener.dataPublisher
            .sink { completion in
                switch completion {
                case let .failure(error):
                    update(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { channels in
                update(.success(channels))
            }
        publisher.store(in: &cancellables)

        let cancelBlock: () -> Void = { [weak channelsListener, weak publisher] in
            channelsListener?.reset(reinitializePublishers: true)
            publisher?.cancel()
        }
        cancel(cancelBlock)
    }

    func getChannelListener(channelId: String,
                            cancel: @escaping (_ cancel: @escaping () -> Void) -> Void,
                            update: @escaping (Result<([Change<Message>], [Message]), AppError>) -> Void) {
        channelListener.reset()
        channelListener.startListening(updateType: .changes, collectionName: "thread",
                                       baseDocumentReference: firestore.collection("channels").document(channelId))

        let publisher = channelListener.changesPublisher
            .sink { completion in
                switch completion {
                case let .failure(error):
                    update(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { changes in
                update(.success(changes))
            }
        publisher.store(in: &cancellables)

        let cancelBlock: () -> Void = { [weak channelListener, weak publisher] in
            channelListener?.reset()
            publisher?.cancel()
        }
        cancel(cancelBlock)
    }

    func sendMessage(user: User, message: String, toChannelWithId channelId: String, completion: @escaping (Result<Void, AppError>) -> Void) {
        getChannel(channelId: channelId) { [weak self] result in
            switch result {
            case let .success(channel):
                let message = Message(user: user, content: message)
                self?.send(message: message, inChannel: channel, completion: { result in
                    switch result {
                    case let .failure(error):
                        completion(.failure(error))
                    case .success():
                        completion(.success(()))
                    }
                })
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func markChannelAsSeen(channel: Channel) {
        guard let userId = userId else { return }

        #warning("mark as seen")
//        var updatedChannel = channel
//        updatedChannel.lastSeenDates[userId] = Date.serverDate
//        update(channel: updatedChannel, fieldsToUpdate: [.lastSeenDates], completion: nil)
    }

    func getOrCreateChannel(users: [User], completion: @escaping (Result<Channel, AppError>) -> Void) {
        let userIds = users.map(\.id).sorted()
        let userIdsJoined = userIds.joined(separator: "")
        if var channel = channelsListener.value.first(where: { $0.userIds == userIds.sorted() }) {
            channel.users = []
            channelCache.insert(channel, forKey: userIdsJoined)
            channel.users = users
            completion(.success(channel))
        } else if var channel = channelCache.value(forKey: userIdsJoined) {
            channel.users = users
            completion(.success(channel))
        } else {
            channelsRef().whereField("userIds", isEqualTo: userIds.sorted()).getDocuments { [weak self] snapshot, error in
                if let data = snapshot?.documents.map({ $0.data() }),
                   let channels = [Channel](from: data),
                   var channel = channels.first(where: { $0.userIds == userIds.sorted() }) {
                    self?.channelCache.insert(channel, forKey: userIdsJoined)
                    channel.users = users
                    completion(.success(channel))
                } else {
                    self?.addChannel(userIds: userIds) { [weak self] result in
                        switch result {
                        case var .success(channel):
                            self?.channelCache.insert(channel, forKey: userIdsJoined)
                            channel.users = users
                            completion(.success(channel))
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }

    func reset() {
        dbListeners.forEach { $0.reset() }
    }
}

private extension ChatWorker {
    func channelsRef() -> CollectionReference {
        firestore.collection(.chat).document(.channels).collection(.channels)
    }

    func channelRef(_ channelId: String) -> DocumentReference {
        channelsRef().document(channelId)
    }

    func getChannel(channelId: String, completion: @escaping (Result<Channel, AppError>) -> Void) {
        channelRef(channelId).getDocument { snapshot, error in
            if let dict = snapshot?.data(), let channel = Channel(from: dict) {
                completion(.success(channel))
            } else if let error = error {
                completion(.failure(AppError(error: error)))
            } else {
                completion(.failure(AppError.unknown))
            }
        }
    }

    func addChannel(userIds: [String], completion: @escaping (Result<Channel, AppError>) -> Void) {
        let channel = Channel(userIds: userIds.sorted())
        update(channel: channel, fieldsToUpdate: nil, completion: completion)
    }

    func send(message: Message, inChannel channel: Channel, completion: @escaping (Result<Void, AppError>) -> Void) {
        let ref = channelRef(channel.id).collection(.thread).document(message.id)
        guard let dict = try? message.asDictionary() else { return }
        setDocument(dict, atRef: ref) { [weak self] error in
            if let error = error {
                completion(.failure(AppError(error: error)))
            } else {
                self?.addLastMessage(toChannel: channel, message: message)
                completion(.success(()))
            }
        }
    }

    func addLastMessage(toChannel channel: Channel, message: Message) {
        var updatedChannel = channel
        #warning("yoo")
//        updatedChannel.lastMessages[message.sender.senderId] = .init(userId: message.sender.senderId, content: message.content, sentDate: Date.serverDate)
//        updatedChannel.updated = Date.serverDate
//        updatedChannel.lastMessageSentDate = Date.serverDate
//
//        update(channel: updatedChannel,
//               fieldsToUpdate: [.lastMessages, .updated, .lastMessageSentDate],
//               completion: nil)
    }

    func update(channel: Channel, fieldsToUpdate: [Channel.CodingKeys]?, completion: ((Result<Channel, AppError>) -> Void)?) {
        let ref = firestore.collection("channels").document(channel.id)

        #warning("yooo")
//        if let fieldsToUpdate = fieldsToUpdate {
//            firestore.runTransaction { transaction, error in
//                let snapshot: DocumentSnapshot
//                do {
//                    try snapshot = transaction.getDocument(ref)
//                } catch let fetchError as NSError {
//                    error?.pointee = fetchError
//                    return nil
//                }
//
//                guard let dict = snapshot.data(), let currentChannel = Channel(from: dict)
//                else { return nil }
//
//                var updates: [AnyHashable: Any] = [:]
//                fieldsToUpdate.forEach { field in
//                    var updateValue: Any? = nil
//                    switch field {
//                    case .id:
//                        break
//                    case .userIds:
//                        updateValue = channel.userIds
//                    case .lastMessages:
//                        var lastMessages = currentChannel.lastMessages
//                        channel.lastMessages.forEach { key, value in
//                            if let currentValue = lastMessages[key] {
//                                if value.sentDate > currentValue.sentDate {
//                                    lastMessages[key] = value
//                                }
//                            } else {
//                                lastMessages[key] = value
//                            }
//                        }
//                        if lastMessages != currentChannel.lastMessages {
//                            updateValue = lastMessages.compactMapValues { try? $0.asDictionary() }
//                        }
//                    case .lastSeenDates:
//                        var lastSeenDates = currentChannel.lastSeenDates
//                        channel.lastSeenDates.forEach { key, value in
//                            if let currentValue = lastSeenDates[key] {
//                                if value > currentValue {
//                                    lastSeenDates[key] = value
//                                }
//                            } else {
//                                lastSeenDates[key] = value
//                            }
//                        }
//                        if lastSeenDates != currentChannel.lastSeenDates {
//                            updateValue = lastSeenDates
//                        }
//                    case .created:
//                        updateValue = channel.created
//                    case .updated:
//                        if channel.updated > currentChannel.updated {
//                            updateValue = channel.updated
//                        }
//                    case .lastMessageSentDate:
//                        if let newValue = channel.lastMessageSentDate {
//                            if let oldValue = currentChannel.lastMessageSentDate {
//                                if newValue > oldValue {
//                                    updateValue = newValue
//                                }
//                            } else {
//                                updateValue = newValue
//                            }
//                        }
//                    }
//                    if let updateValue = updateValue {
//                        updates[field.rawValue] = updateValue
//                    }
//                }
//                if !updates.isEmpty {
//                    transaction.updateData(updates, forDocument: ref)
//                    if var updatedChannelDict = try? currentChannel.asDictionary() as [AnyHashable: Any] {
//                        updates.forEach { key, value in
//                            updatedChannelDict[key] = value
//                        }
//                        if let updatedChannel = Channel(from: updatedChannelDict) {
//                            return updatedChannel
//                        }
//                    }
//                }
//                return nil
//            } completion: { object, error in
//                if let error = error {
//                    completion?(.failure(AppError(error: error)))
//                } else if let newChannel = object as? Channel {
//                    completion?(.success(newChannel))
//                } else {
//                    completion?(.failure(AppError(title: "Error", message: "Nothing to update", error: nil)))
//                }
//            }
//        } else {
//            if let dict = try? channel.asDictionary() {
//                ref.setData(dict)
//            }
//        }
    }

}
