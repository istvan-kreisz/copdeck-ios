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
    
    private var channels: [Channel] = []

    private let channelCache = Cache<String, Channel>(entryLifetimeMin: 60)

    // collection listeners
    private var channelListener = CollectionListener<Message>()

    // document listeners
    private var chatUpdatesListener = DocumentListener<ChatUpdateInfo>()

    var dbListeners: [FireStoreListener] {
        let listeners: [FireStoreListener?] = [channelListener, chatUpdatesListener]
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
        chatUpdatesListener.startListening(documentRef: updateInfoRef(userId))
    }

    func getChannels(update: @escaping (Result<[Channel], AppError>) -> Void) {
        guard let userId = userId else { return }

        channelsRef()
            .whereField("userIds", arrayContains: userId)
            .whereField("isEmpty", isNotEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching documents: \(error)")
                    update(.failure(AppError(error: error)))
                } else {
                    if let channels = snapshot?.documents.compactMap({ Channel(from: $0.data()) }) {
                        update(.success(channels))
                    } else {
                        update(.failure(AppError.wrongData))
                    }
                }
            }
    }

    func getChannelListener(channelId: String,
                            cancel: @escaping (_ cancel: @escaping () -> Void) -> Void,
                            update: @escaping (Result<([Change<Message>], [Message]), AppError>) -> Void) {
        channelListener.reset()
        channelListener.startListening(updateType: .changes, collectionRef: channelRef(channelId).collection(.thread))

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

    func sendMessage(user: User, message: String, toChannel channel: Channel, completion: @escaping (Result<Void, AppError>) -> Void) {
        let message = Message(user: user, channelUserIds: channel.userIds, content: message)
        send(message: message, inChannel: channel, completion: { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case .success():
                completion(.success(()))
            }
        })
    }

    func markChannelAsSeen(channel: Channel) {
        guard let userId = userId else { return }

        let updateData = ["updateInfo": ["\(channel.id)": ["lastSeenDate": Date.serverDate]]]
        setDocument(updateData, atRef: updateInfoRef(userId), updateDates: false) { error in
            if let error = error {
                log(error, logType: .error)
            }
        }
    }

    func getOrCreateChannel(users: [User], completion: @escaping (Result<Channel, AppError>) -> Void) {
        let userIds = users.map(\.id).sorted()
        let userIdsJoined = userIds.joined(separator: "")
        if var channel = channels.first(where: { $0.userIds == userIds.sorted() }) {
            channel.users = []
            channelCache.insert(channel, forKey: userIdsJoined)
            channel.users = users
            completion(.success(channel))
        } else if var channel = channelCache.value(forKey: userIdsJoined) {
            channel.users = users
            completion(.success(channel))
        } else {
            channelsRef()
                .whereField("userIds", isEqualTo: userIds.sorted())
                .getDocuments { [weak self] snapshot, error in
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
        cancellables.forEach { $0.cancel() }
        channels = []
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

    func updateInfoRef(_ userId: String) -> DocumentReference {
        firestore.collection(.chat).document(.updateInfo).collection(.updateInfo).document(userId)
    }

    func addChannel(userIds: [String], completion: @escaping (Result<Channel, AppError>) -> Void) {
        let channel = Channel(userIds: userIds.sorted())
        add(channel: channel, completion: completion)
    }

    func send(message: Message, inChannel channel: Channel, completion: @escaping (Result<Void, AppError>) -> Void) {
        guard let newMessageDict = try? message.asDictionary() else { return }

        let batch = firestore.batch()

        // 1. send message
        let newMessageRef = channelRef(channel.id).collection(.thread).document(message.id)
        batch.setData(newMessageDict, forDocument: newMessageRef)

        // 2. update channel if channel.isEmpty == true
        if channel.isEmpty {
            let cRef = channelRef(channel.id)
            let channelDict = ["isEmpty": false]
            batch.setData(channelDict, forDocument: cRef, merge: true)
        }

        // 3. update all chatUpdateInfos for all users
        let lastMessage = ChatUpdateInfo.LastMessage(userId: message.sender.senderId, content: message.content, sentDate: message.dateSent)
        if let lastMessageDict = try? lastMessage.asDictionary() {
            channel.userIds.forEach { userId in
                let ref = updateInfoRef(userId)
                let updateData = ["updateInfo": ["\(channel.id)": ["lastMessage": lastMessageDict]]]
                batch.setData(updateData, forDocument: ref, merge: true)
            }
        }

        // 4. commit changes
        batch.commit { [weak self] error in
            if let error = error {
                log(error, logType: .error)
                self?.errorsSubject.send(AppError.unknown)
            }
        }
    }

    func add(channel: Channel, completion: ((Result<Channel, AppError>) -> Void)?) {
        guard let dict = try? channel.asDictionary() else {
            completion?(.failure(.wrongData))
            return
        }
        setDocument(dict, atRef: channelRef(channel.id)) { error in
            if let error = error {
                completion?(.failure(AppError(error: error)))
            } else {
                completion?(.success(channel))
            }
        }
    }
}
