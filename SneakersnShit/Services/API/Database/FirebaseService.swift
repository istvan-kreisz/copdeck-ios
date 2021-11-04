//
//  FirebaseService.swift
//  CopDeck
//
//  Created by István Kreisz on 4/7/20.
//  Copyright © 2020 István Kreisz. All rights reserved.
//

import Firebase
import Combine
import UIKit

class FirebaseService: DatabaseManager {
    private static let recentlyViewedLimit = 20

    enum DBRef: String {
        case notificationTokens
    }

    private let firestore: Firestore
    private var userId: String?

    var cancellables: Set<AnyCancellable> = []
    private let channelCache = Cache<String, Channel>(entryLifetimeMin: 60)

    // collection listeners
    private var inventoryListener = CollectionListener<InventoryItem>()
    private var stacksListener = CollectionListener<Stack>()
    private var favoritesListener = CollectionListener<Item>()
    private var recentlyViewedListener = CollectionListener<Item>()
    private var channelsListener = CollectionListener<Channel>()
    private var channelListener = CollectionListener<Message>()

    // document listeners
    private var userListener = DocumentListener<User>()
    private var exchangeRatesListener = DocumentListener<ExchangeRates>()

    private let errorsSubject = PassthroughSubject<AppError, Never>()

    private var dbListeners: [FireStoreListener] {
        let listeners: [FireStoreListener?] = [inventoryListener,
                                               stacksListener,
                                               favoritesListener,
                                               recentlyViewedListener,
                                               userListener,
                                               exchangeRatesListener,
                                               channelsListener,
                                               channelListener]
        return listeners.compactMap { $0 }
    }

    // collection publishers
    var inventoryItemsPublisher: AnyPublisher<[InventoryItem], AppError> {
        inventoryListener.dataPublisher
    }

    var favoritesPublisher: AnyPublisher<[Item], AppError> {
        favoritesListener.dataPublisher
    }

    var recentlyViewedPublisher: AnyPublisher<[Item], AppError> {
        recentlyViewedListener.dataPublisher
    }

    var stacksPublisher: AnyPublisher<[Stack], AppError> {
        stacksListener.dataPublisher
    }

    // document publishers
    var userPublisher: AnyPublisher<User, AppError> {
        userListener.dataPublisher.compactMap { $0 }.eraseToAnyPublisher()
    }

    var exchangeRatesPublisher: AnyPublisher<ExchangeRates, AppError> {
        exchangeRatesListener.dataPublisher.compactMap { $0 }.eraseToAnyPublisher()
    }

    var errorsPublisher: AnyPublisher<AppError, Never> {
        errorsSubject.eraseToAnyPublisher()
    }

    private var itemsRef: CollectionReference?

    init() {
        firestore = Firestore.firestore()
        let settings = firestore.settings
        settings.cacheSizeBytes = 200 * 1_000_000
        if DebugSettings.shared.isInDebugMode, DebugSettings.shared.useFirestoreEmulator {
            settings.host = "\(DebugSettings.shared.ipAddress):8080"
            settings.isPersistenceEnabled = false
            settings.isSSLEnabled = false
        }
        firestore.settings = settings

        itemsRef = firestore.collection("items")
        exchangeRatesListener.startListening(documentRef: firestore.collection("info").document("exchangerates"))
    }

    func setup(userId: String) {
        guard userId != self.userId else { return }
        reset()

        self.userId = userId
        listenToChanges(userId: userId)
    }

    private func listenToChanges(userId: String) {
        userListener.startListening(documentRef: firestore.collection("users").document(userId))
        inventoryListener.startListening(collectionName: "inventory", baseDocumentReference: userListener.documentRef)
        stacksListener.startListening(collectionName: "stacks", baseDocumentReference: userListener.documentRef)
        favoritesListener.startListening(collectionName: "favorites", baseDocumentReference: userListener.documentRef)
        recentlyViewedListener.startListening(collectionName: "recentlyViewed", baseDocumentReference: userListener.documentRef)
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
            firestore.collection("channels").whereField("userIds", isEqualTo: userIds.sorted()).getDocuments { [weak self] snapshot, error in
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

    private func getChannel(channelId: String, completion: @escaping (Result<Channel, AppError>) -> Void) {
        firestore.collection("channels").document(channelId).getDocument { snapshot, error in
            if let dict = snapshot?.data(), let channel = Channel(from: dict) {
                completion(.success(channel))
            } else if let error = error {
                completion(.failure(AppError(error: error)))
            } else {
                completion(.failure(AppError.unknown))
            }
        }
    }

    private func addChannel(userIds: [String], completion: @escaping (Result<Channel, AppError>) -> Void) {
        let channel = Channel(userIds: userIds.sorted())
        update(channel: channel, fieldsToUpdate: nil, completion: completion)
    }

    private func send(message: Message, inChannel channel: Channel, completion: @escaping (Result<Void, AppError>) -> Void) {
        let ref = firestore.collection("channels").document(channel.id).collection("thread").document(message.id)
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

    private func addLastMessage(toChannel channel: Channel, message: Message) {
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

    private func update(channel: Channel, fieldsToUpdate: [Channel.CodingKeys]?, completion: ((Result<Channel, AppError>) -> Void)?) {
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

    private func addCollectionUpdatesListener<T: Codable>(collectionRef: CollectionReference?,
                                                          updated: @escaping (_ added: [T], _ removed: [T], _ modified: [T]) -> Void)
        -> ListenerRegistration? {
        collectionRef?
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching documents: \(error)")
                    return
                }
                var added: [T] = []
                var modified: [T] = []
                var removed: [T] = []
                snapshot?.documentChanges.forEach { diff in
                    let dict = diff.document.data()
                    guard let element = T(from: dict) else { return }
                    switch diff.type {
                    case .added:
                        added.append(element)
                    case .modified:
                        modified.append(element)
                    case .removed:
                        removed.append(element)
                    }
                }
                updated(added, removed, modified)
            }
    }

    func reset() {
        dbListeners.forEach { $0.reset() }
        userId = nil
    }

    func getUser(withId id: String) -> AnyPublisher<User, AppError> {
        Future { [weak self] promise in
            self?.firestore.collection("users").document(id).getDocument { snapshot, error in
                if let dict = snapshot?.data(), var user = User(from: dict) {
                    user.settings = user.settings ?? CopDeckSettings.default
                    promise(.success(user))
                } else if let error = error {
                    promise(.failure(AppError(error: error)))
                } else {
                    var user = User(id: id)
                    user.settings = user.settings ?? CopDeckSettings.default
                    promise(.success(user))
                }
            }
        }.eraseToAnyPublisher()
    }

    func getItem(withId id: String, settings: CopDeckSettings) -> AnyPublisher<Item, AppError> {
        return Future { [weak self] promise in
            self?.itemsRef?.document(Item.databaseId(itemId: id, settings: settings)).getDocument { snapshot, error in
                log("db read itemId: \(id)", logType: .database)
                if let dict = snapshot?.data(), let item = Item(from: dict) {
                    promise(.success(item))
                } else {
                    promise(.failure(error.map { AppError(error: $0) } ?? AppError.unknown))
                }
            }
        }.eraseToAnyPublisher()
    }

    func delete(inventoryItems: [InventoryItem]) {
        let batch = firestore.batch()
        // update inventory items
        inventoryItems
            .forEach { inventoryItem in
                _ = (inventoryListener.collectionRef?.document(inventoryItem.id))
                    .map { [weak self] in
                        self?.deleteDocument(atRef: $0, using: batch)
                    }
            }
        // update stacks
        stacksListener.dataSubject
            .value
            .filter { stack in
                stack.items
                    .map(\.inventoryItemId)
                    .contains(where: { id in
                        inventoryItems.map(\.id).contains(id)
                    })
            }
            .map { stack -> Stack in
                var updatedStack = stack
                updatedStack.items = updatedStack.items
                    .filter { item in
                        !inventoryItems.map(\.id).contains(item.inventoryItemId)
                    }
                return updatedStack
            }
            .forEach { stack in
                _ = (stacksListener.collectionRef?.document(stack.id))
                    .map { [weak self] ref in
                        if let data = try? stack.asDictionary() {
                            self?.updateDocument(data, atRef: ref, using: batch)
                        }
                    }
            }

        batch.commit { [weak self] error in
            if let error = error {
                self?.errorsSubject.send(AppError(error: error))
            }
        }
    }

    func update(stacks: [Stack]) {
        let batch = firestore.batch()
        // update inventory items
        let stacksToUpdate = stacks
            .map { stack in
                var updatedStack = stack
                if updatedStack.isPublished ?? false, updatedStack.publishedDate == nil {
                    updatedStack.publishedDate = Date.serverDate
                }
                return updatedStack
            }
            .compactMap { (stack: Stack) -> ([String: Any], DocumentReference)? in
                if let dict = try? stack.asDictionary(), let ref = stacksListener.collectionRef?.document(stack.id) {
                    return (dict, ref)
                } else {
                    return nil
                }
            }

        if stacksToUpdate.count == 1 {
            if let (dict, ref) = stacksToUpdate.first {
                setDocument(dict, atRef: ref)
            }
        } else {
            stacksToUpdate
                .forEach { dict, ref in
                    setDocument(dict, atRef: ref, using: batch)
                }
            batch.commit { [weak self] error in
                if let error = error {
                    self?.errorsSubject.send(AppError(error: error))
                }
            }
        }
    }

    func delete(stack: Stack) {
        guard let ref = stacksListener.collectionRef?.document(stack.id) else { return }
        deleteDocument(atRef: ref)
    }

    func add(inventoryItems: [InventoryItem]) {
        let batch = firestore.batch()
        inventoryItems
            .compactMap { inventoryItem -> (String, [String: Any])? in
                (try? inventoryItem.asDictionary()).map { (inventoryItem.id, $0) } ?? nil
            }
            .forEach { [weak self] id, dict in
                if let ref = inventoryListener.collectionRef?.document(id) {
                    self?.setDocument(dict, atRef: ref, using: batch)
                }
            }

        batch.commit { [weak self] error in
            if let error = error {
                self?.errorsSubject.send(AppError(error: error))
            }
        }
    }

    func update(inventoryItem: InventoryItem) {
        guard let dict = try? inventoryItem.asDictionary(),
              let ref = inventoryListener.collectionRef?.document(inventoryItem.id)
        else { return }
        setDocument(dict, atRef: ref)
    }

    func update(user: User) {
        guard let dict = try? user.asDictionary(), let ref = userListener.documentRef else { return }
        setDocument(dict, atRef: ref)
    }

    func add(recentlyViewedItem: Item) {
        let recentlyViewed = recentlyViewedListener.dataSubject.value
        guard !recentlyViewed.contains(where: { $0.id == recentlyViewedItem.id }) else { return }

        let batch = firestore.batch()

        // delete old ones if over limit
        if recentlyViewed.count >= Self.recentlyViewedLimit - 1 {
            let mostRecents = recentlyViewed.sortedByDate(sortOrder: .descending).first(n: Self.recentlyViewedLimit - 1)
            let mostRecentIds = mostRecents.map(\.id)
            let deleted = recentlyViewed.filter { !mostRecentIds.contains($0.id) }
            let deletedDocRefs = deleted.compactMap { recentlyViewedListener.collectionRef?.document(Item.databaseId(itemId: $0.id, settings: nil)) }
            deletedDocRefs.forEach { [weak self] in
                self?.deleteDocument(atRef: $0, using: batch)
            }
        }
        // add new
        log("add new recentlyViewedItem \(recentlyViewedItem.id)", logType: .database)
        if let dict = try? recentlyViewedItem.strippedOfPrices.asDictionary() {
            if let newDocumentRef = recentlyViewedListener.collectionRef?.document(Item.databaseId(itemId: recentlyViewedItem.id, settings: nil)) {
                setDocument(dict, atRef: newDocumentRef, using: batch)
            }
        }

        batch.commit { [weak self] error in
            if let error = error {
                self?.errorsSubject.send(AppError(error: error))
            }
        }
    }

    func favorite(item: Item) {
        guard !favoritesListener.dataSubject.value.contains(where: { $0.id == item.id }) else { return }
        guard let dict = try? item.strippedOfPrices.asDictionary(),
              let ref = favoritesListener.collectionRef?.document(Item.databaseId(itemId: item.id, settings: nil))
        else { return }
        setDocument(dict, atRef: ref)
    }

    func unfavorite(item: Item) {
        guard let ref = favoritesListener.collectionRef?.document(Item.databaseId(itemId: item.id, settings: nil)) else { return }
        deleteDocument(atRef: ref)
    }

    func getSpreadsheetImportWaitlist(completion: @escaping (Result<[User], Error>) -> Void) {
        guard DebugSettings.shared.isAdmin else { return }
        firestore
            .collection("users")
            .whereField("spreadsheetImport.status", in: User.SpreadSheetImportStatus.allCases.map(\.rawValue))
            .order(by: "spreadsheetImport.date", descending: true)
            .getDocuments { [weak self] snapshot, error in
                self?.parseUsers(snapshot: snapshot, error: error, completion: completion)
            }
    }

    private func parseUsers(snapshot: QuerySnapshot?, error: Error?, completion: @escaping (Result<[User], Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
        } else {
            if let users = snapshot?.documents.compactMap({ User(from: $0.data()) }) {
                completion(.success(users))
            } else {
                completion(.failure(AppError.unknown))
            }
        }
    }

    private func setDocument(_ data: [String: Any], atRef ref: DocumentReference, using batch: WriteBatch? = nil, completion: ((Error?) -> Void)? = nil) {
        let data = dataWithUpdatedDates(data)
        if let batch = batch {
            batch.setData(data, forDocument: ref, merge: true)
        } else {
            ref.setData(data, merge: true) { [weak self] error in
                if let error = error {
                    self?.errorsSubject.send(AppError(error: error))
                }
                completion?(error)
            }
        }
    }

    private func updateDocument(_ data: [String: Any], atRef ref: DocumentReference, using batch: WriteBatch? = nil, completion: ((Error?) -> Void)? = nil) {
        let data = dataWithUpdatedDates(data)
        if let batch = batch {
            batch.updateData(data, forDocument: ref)
        } else {
            ref.updateData(data) { [weak self] error in
                if let error = error {
                    self?.errorsSubject.send(AppError(error: error))
                }
                completion?(error)
            }
        }
    }

    private func deleteDocument(atRef ref: DocumentReference, using batch: WriteBatch? = nil, completion: ((Error?) -> Void)? = nil) {
        if let batch = batch {
            batch.deleteDocument(ref)
        } else {
            ref.delete { [weak self] error in
                if let error = error {
                    self?.errorsSubject.send(AppError(error: error))
                }
                completion?(error)
            }
        }
    }

    private func dataWithUpdatedDates(_ data: [String: Any]) -> [String: Any] {
        var copy = data
        if copy["created"] == nil {
            copy["created"] = Date.serverDate
        }
        copy["updated"] = Date.serverDate
        return copy
    }

    func getToken(byId id: String, completion: @escaping (NotificationToken?) -> Void) {
        firestore.collection(DBRef.notificationTokens.rawValue).document(id).getDocument { snapshot, error in
            if let dict = snapshot?.data(), let token = NotificationToken(from: dict) {
                completion(token)
            } else {
                completion(nil)
            }
        }
    }

    func setToken(_ token: NotificationToken, completion: @escaping (AppError?) -> Void) {
        firestore
            .collection(DBRef.notificationTokens.rawValue)
            .whereField("deviceId", isEqualTo: token.deviceId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let data = snapshot?.documents.map({ $0.data() }), let tokens = [NotificationToken](from: data) {
                    tokens
                        .filter { $0.token != token.token }
                        .forEach { token in
                            self.deleteToken(token) { _ in }
                        }
                    self.addToken(token, completion: completion)
                } else {
                    self.addToken(token, completion: completion)
                }
            }
    }

    private func addToken(_ token: NotificationToken, completion: @escaping (AppError?) -> Void) {
        guard let dict = try? token.asDictionary() else {
            completion(AppError.unknown)
            return
        }

        let ref = firestore.collection(DBRef.notificationTokens.rawValue).document(token.token)
        setDocument(dict, atRef: ref) { error in
            completion(error.map { AppError(error: $0) })
        }
    }

    func deleteToken(_ token: NotificationToken, completion: @escaping (AppError?) -> Void) {
        deleteToken(byId: token.token, completion: completion)
    }
    
    func deleteToken(byId id: String, completion: @escaping (AppError?) -> Void) {
        firestore.collection(DBRef.notificationTokens.rawValue).document(id).delete { error in
            completion(error.map { AppError(error: $0) })
        }
    }

}
