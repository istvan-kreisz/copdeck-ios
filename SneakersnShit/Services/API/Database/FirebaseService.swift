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

    private let firestore: Firestore
    private var userId: String?

    var cancellables: Set<AnyCancellable> = []

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

        channelsListener.reset()
        channelsListener.startListening(collectionName: "channels", firestore: firestore) { $0?.whereField("userIds", arrayContains: userId) }

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
            channelsListener?.reset()
            publisher?.cancel()
        }
        cancel(cancelBlock)
    }

    func getChannelListener(channelId: String,
                            cancel: @escaping (_ cancel: @escaping () -> Void) -> Void,
                            update: @escaping (Result<[Message], AppError>) -> Void) {
        channelListener.reset()
        channelListener.startListening(collectionName: "thread", baseDocumentReference: firestore.collection("channels").document(channelId))

        let publisher = channelListener.dataPublisher
            .sink { completion in
                switch completion {
                case let .failure(error):
                    update(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { messages in
                update(.success(messages.sorted(by: { $0.dateSent < $1.dateSent })))
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

        var updatedChannel = channel
        updatedChannel.lastSeenDates[userId] = Date.serverDate
        update(channel: updatedChannel, completion: nil)
    }
    
    func getOrCreateChannel(userIds: [String], completion: @escaping (Result<Channel, AppError>) -> Void) {
        if let channel = channelsListener.value.first(where: { $0.userIds == userIds.sorted() }) {
            completion(.success(channel))
        } else {
            firestore.collection("channels").whereField("userIds", isEqualTo: userIds.sorted()).getDocuments { [weak self] snapshot, error in
                if let data = snapshot?.documents.map({ $0.data() }),
                   let channels = [Channel](from: data),
                   let channel = channels.first(where: { $0.userIds == userIds.sorted() }) {
                    completion(.success(channel))
                } else {
                    self?.addChannel(userIds: userIds) { result in
                        switch result {
                        case let .success(channel):
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
        update(channel: channel, completion: completion)
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
        updatedChannel.lastMessages[message.sender.senderId] = .init(userId: message.sender.senderId, content: message.content, sentDate: Date.serverDate)
        updatedChannel.updated = Date.serverDate

        update(channel: updatedChannel, completion: nil)
    }

    private func update(channel: Channel, completion: ((Result<Channel, AppError>) -> Void)?) {
        let ref = firestore.collection("channels").document(channel.id)
        guard let dict = try? channel.asDictionary() else { return }
        setDocument(dict, atRef: ref) { error in
            guard let completion = completion else { return }
            if let error = error {
                completion(.failure(AppError(error: error)))
            } else {
                completion(.success(channel))
            }
        }
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

    #warning("indexxx")
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
}
