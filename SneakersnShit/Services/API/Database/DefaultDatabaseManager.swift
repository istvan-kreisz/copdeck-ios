//
//  DefaultDatabaseManager.swift
//  CopDeck
//
//  Created by István Kreisz on 4/7/20.
//  Copyright © 2020 István Kreisz. All rights reserved.
//

import Firebase
import Combine
import UIKit

class DefaultDatabaseManager: DatabaseManager, FirestoreWorker {
    private static let recentlyViewedLimit = 30

    let firestore: Firestore
    var userId: String?
    private lazy var chatWorker = ChatWorker(delegate: self)

    var cancellables: Set<AnyCancellable> = []

    // collection listeners
    private var inventoryListener = CollectionListener<InventoryItem>()
    private var stacksListener = CollectionListener<Stack>()
    private var favoritesListener = CollectionListener<Item>()
    private var recentlyViewedListener = CollectionListener<Item>()

    // document listeners
    private var userListener = DocumentListener<User>()
    private var lastPriceViewsListenerUser = DocumentListener<LastPriceViews>()
    private var lastPriceViewsListenerDevice = DocumentListener<LastPriceViews>()
    private var itemListener: DocumentListener<Item>?

    let errorsSubject = PassthroughSubject<AppError, Never>()

    var dbListeners: [FireStoreListener] {
        let listeners: [FireStoreListener?] = [inventoryListener,
                                               stacksListener,
                                               favoritesListener,
                                               recentlyViewedListener,
                                               userListener,
                                               lastPriceViewsListenerUser,
                                               lastPriceViewsListenerDevice,
                                               itemListener] + chatWorker.dbListeners
        return listeners.compactMap { $0 }
    }

    // collection publishers
    var inventoryItemsPublisher: AnyPublisher<[InventoryItem], AppError> {
        inventoryListener.dataPublisher
    }

    var favoritesPublisher: AnyPublisher<[Item], AppError> {
        favoritesListener.dataPublisher.map { $0.sortedByDate(dateType: .updated, sortOrder: .descending) }.eraseToAnyPublisher()
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

    var canViewPricesPublisher: AnyPublisher<Bool, AppError> {
        lastPriceViewsListenerUser.dataPublisher.combineLatest(lastPriceViewsListenerDevice.dataPublisher)
            .map { new in
                guard AppStore.default.state.isContentLocked else { return true }
                let lastPriceViewsCountUser = new.0?.values.count ?? 0
                let lastPriceViewsCountDevice = new.1?.values.count ?? 0
                return lastPriceViewsCountUser < World.Constants.lifetimePriceCheckLimit && lastPriceViewsCountDevice < World.Constants.lifetimePriceCheckLimit
            }
            .eraseToAnyPublisher()
    }

    var chatUpdatesPublisher: AnyPublisher<ChatUpdateInfo, AppError> {
        chatWorker.chatUpdatesPublisher
    }

    var errorsPublisher: AnyPublisher<AppError, Never> {
        errorsSubject.merge(with: chatWorker.errorsSubject).eraseToAnyPublisher()
    }

    init() {
        // firestore
        firestore = Firestore.firestore()
        let settings = firestore.settings
        settings.cacheSizeBytes = 200 * 1_000_000
        if DebugSettings.shared.isInDebugMode, DebugSettings.shared.useFirestoreEmulator {
            settings.host = "\(DebugSettings.shared.ipAddress):8080"
            settings.isPersistenceEnabled = false
            settings.isSSLEnabled = false
        }
        firestore.settings = settings
    }

    func setup(userId: String) {
        guard userId != self.userId else { return }
        reset()

        self.userId = userId
        listenToChanges(userId: userId)
    }

    func listenToChanges(userId: String) {
        let userRef = firestore.collection(.users).document(userId)
        userListener.startListening(documentRef: userRef)
        lastPriceViewsListenerUser.startListening(documentRef: firestore.collection(.lastPriceViews).document(userId))
        lastPriceViewsListenerDevice.startListening(documentRef: firestore.collection(.lastPriceViews).document(PushNotificationService.deviceId))

        inventoryListener.startListening(collectionRef: userRef.collection(.inventory))
        stacksListener.startListening(collectionRef: userRef.collection(.stacks))
        favoritesListener.startListening(collectionRef: userRef.collection(.favorites))
        recentlyViewedListener.startListening(collectionRef: userRef.collection(.recentlyViewed))

        chatWorker.listenToChanges(userId: userId)
    }

    func reset() {
        dbListeners.forEach { $0.reset() }
        userId = nil
    }

    func getUser(withId id: String) -> AnyPublisher<User, AppError> {
        Future { [weak self] promise in
            self?.firestore.collection(.users).document(id).getDocument { snapshot, error in
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

    func getItem(withId id: String, settings: CopDeckSettings, completion: @escaping (Result<Item, AppError>) -> Void) {
        firestore.collection(.items).document(Item.databaseId(itemId: id, settings: settings)).getDocument { snapshot, error in
            log("db read itemId: \(id)", logType: .database)
            if let dict = snapshot?.data(), let item = Item(from: dict) {
                completion(.success(item))
            } else {
                completion(.failure(error.map { AppError(error: $0) } ?? AppError.unknown))
            }
        }
    }

    func getItems(withIds ids: [String], settings: CopDeckSettings, completion: @escaping ([Item]) -> Void) {
        var items: [Item] = []
        let dispatchGroup = DispatchGroup()

        for id in Array(Set(ids)) {
            dispatchGroup.enter()
            getItem(withId: id, settings: settings) { result in
                switch result {
                case .failure:
                    break
                case let .success(item):
                    items.append(item)
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(items)
        }
    }

    func getItemListener(withId id: String, settings: CopDeckSettings, updated: @escaping (Item) -> Void) -> DocumentListener<Item> {
        itemListener?.reset()
        let listener = DocumentListener<Item>()
        let ref = firestore.collection(.items).document(Item.databaseId(itemId: id, settings: settings))
        listener.startListening(documentRef: ref, updated: updated)
        self.itemListener = listener
        return listener
    }

    func getPopularItems() -> AnyPublisher<[ItemSearchResult], AppError> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(AppError.notFound(val: "")))
                return
            }
            self.getCollection(atRef: self.firestore.collection(.popularItems)) { (result: Result<[Item], Error>) in
                switch result {
                case let .success(items):
                    promise(.success(items.map { ItemSearchResult(from: $0) }))
                case let .failure(error):
                    promise(.failure(AppError(error: error)))
                }
            }
        }.eraseToAnyPublisher()
    }

    static var exchangeRatesFetchCount = 0
    static var sizeConversionFetchCount = 0
    static var remoteConfigFetchCount = 0

    func getExchangeRates(completion: @escaping (ExchangeRates) -> Void) {
        getDocument(atRef: firestore.collection(.info).document(.exchangerates)) { (result: Result<ExchangeRates, Error>) in
            Self.exchangeRatesFetchCount += 1
            switch result {
            case let .success(exchangeRates):
                completion(exchangeRates)
            case .failure:
                let time: TimeInterval
                if Self.exchangeRatesFetchCount <= 1 {
                    time = 1
                } else if Self.exchangeRatesFetchCount == 2 {
                    time = 5
                } else {
                    time = 30
                }
                delay(time) { [weak self] in
                    self?.getExchangeRates(completion: completion)
                }
            }
        }
    }

    func getSizeConversions(completion: @escaping ([SizeConversion]) -> Void) {
        getCollection(atRef: firestore.collection(.sizeConversions)) { (result: Result<[SizeConversion], Error>) in
            Self.sizeConversionFetchCount += 1
            switch result {
            case let .success(conversions):
                completion(conversions)
            case .failure:
                let time: TimeInterval
                if Self.sizeConversionFetchCount <= 1 {
                    time = 1
                } else if Self.sizeConversionFetchCount == 2 {
                    time = 5
                } else {
                    time = 30
                }
                delay(time) { [weak self] in
                    self?.getSizeConversions(completion: completion)
                }
            }
        }
    }

    func getRemoteConfig(completion: @escaping (RemoteConfig) -> Void) {
        getDocument(atRef: firestore.collection(.info).document(.config)) { (result: Result<RemoteConfig, Error>) in
            Self.remoteConfigFetchCount += 1
            switch result {
            case let .success(remoteConfig):
                completion(remoteConfig)
            case .failure:
                let time: TimeInterval
                if Self.remoteConfigFetchCount <= 1 {
                    time = 1
                } else if Self.remoteConfigFetchCount == 2 {
                    time = 5
                } else {
                    time = 30
                }
                delay(time) { [weak self] in
                    self?.getRemoteConfig(completion: completion)
                }
            }
        }
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
        // todo: move this logic to the backend
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
                            self?.setDocument(data, atRef: ref, merge: true, using: batch)
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
                setDocument(dict, atRef: ref, merge: true)
            }
        } else {
            stacksToUpdate
                .forEach { dict, ref in
                    setDocument(dict, atRef: ref, merge: true, using: batch)
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

    func add(inventoryItems: [InventoryItem], completion: @escaping (Result<[InventoryItem], Error>) -> Void) {
        let batch = firestore.batch()
        inventoryItems
            .compactMap { inventoryItem -> (String, [String: Any])? in
                (try? inventoryItem.asDictionary()).map { (inventoryItem.id, $0) } ?? nil
            }
            .forEach { [weak self] id, dict in
                if let ref = inventoryListener.collectionRef?.document(id) {
                    self?.setDocument(dict, atRef: ref, merge: true, using: batch)
                }
            }
        batch.commit { [weak self] error in
            if let error = error {
                completion(.failure(error))
                self?.errorsSubject.send(AppError(error: error))
            } else {
                completion(.success(inventoryItems))
            }
        }
    }

    func update(inventoryItem: InventoryItem) {
        guard let dict = try? inventoryItem.asDictionary(),
              let ref = inventoryListener.collectionRef?.document(inventoryItem.id)
        else { return }
        setDocument(dict, atRef: ref, merge: false)
    }

    func update(user: User) {
        guard let dict = try? user.asDictionary(), let ref = userListener.documentRef else { return }
        setDocument(dict, atRef: ref, merge: false)
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
                setDocument(dict, atRef: newDocumentRef, merge: true, using: batch)
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
        var newItem = item.strippedOfPrices
        newItem.updated = Date.serverDate
        guard let dict = try? newItem.asDictionary(),
              let ref = favoritesListener.collectionRef?.document(Item.databaseId(itemId: newItem.id, settings: nil))
        else { return }
        setDocument(dict, atRef: ref, merge: true)
    }

    func unfavorite(item: Item) {
        guard let ref = favoritesListener.collectionRef?.document(Item.databaseId(itemId: item.id, settings: nil)) else { return }
        deleteDocument(atRef: ref)
    }

    func updateLastPriceViews(docId: String?, itemId: String, listener: DocumentListener<LastPriceViews>) {
        guard let docId = docId else { return }
        let currentValues = listener.dataSubject.value?.values ?? []
        guard currentValues.count < World.Constants.lifetimePriceCheckLimit, !currentValues.contains(where: { viewInfo in
            viewInfo.itemId == itemId && !viewInfo.viewedDate.isOlderThan(minutes: World.Constants.itemPricesRefreshPeriodMin)
        })
        else { return }
        let newValues = (currentValues + [LastPriceViews.ViewInfo(itemId: itemId, viewedDate: Date.serverDate)])
            .sorted(by: { $0.viewedDate > $1.viewedDate })
            .first(n: World.Constants.lifetimePriceCheckLimit)
        let updatedLastPriceViews = LastPriceViews(values: newValues)
        guard let dict = try? updatedLastPriceViews.asDictionary() else { return }
        setDocument(dict, atRef: firestore.collection(.lastPriceViews).document(docId), merge: false)
    }

    func updateLastPriceViews(itemId: String) {
        updateLastPriceViews(docId: userId, itemId: itemId, listener: lastPriceViewsListenerUser)
        updateLastPriceViews(docId: PushNotificationService.deviceId, itemId: itemId, listener: lastPriceViewsListenerDevice)
    }

    func getSpreadsheetImportWaitlist(completion: @escaping (Result<[User], Error>) -> Void) {
        guard DebugSettings.shared.isAdmin else { return }
        firestore
            .collection(.users)
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

    func getToken(byId id: String, completion: @escaping (NotificationToken?) -> Void) {
        firestore.collection(.notificationTokens).document(id).getDocument { snapshot, error in
            if let dict = snapshot?.data(), let token = NotificationToken(from: dict) {
                completion(token)
            } else {
                completion(nil)
            }
        }
    }

    func setToken(_ token: NotificationToken, completion: @escaping (Result<[NotificationToken], AppError>) -> Void) {
        firestore
            .collection(.notificationTokens)
            .whereField("deviceId", isEqualTo: token.deviceId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let data = snapshot?.documents.map({ $0.data() }), let tokens = [NotificationToken](from: data) {
                    let tokensToDelete = tokens.filter { $0.token != token.token }
                    self.addToken(token) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(tokensToDelete))
                        }
                    }
                } else {
                    self.addToken(token) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success([]))
                        }
                    }
                }
            }
    }

    private func addToken(_ token: NotificationToken, completion: @escaping (AppError?) -> Void) {
        guard let dict = try? token.asDictionary() else {
            completion(AppError.unknown)
            return
        }

        let ref = firestore.collection(.notificationTokens).document(token.token)
        setDocument(dict, atRef: ref, merge: true) { error in
            completion(error.map { AppError(error: $0) })
        }
    }

    func deleteToken(_ token: NotificationToken, completion: @escaping (AppError?) -> Void) {
        deleteToken(byId: token.token, completion: completion)
    }

    func deleteToken(byId id: String, completion: @escaping (AppError?) -> Void) {
        firestore.collection(.notificationTokens).document(id).delete { error in
            completion(error.map { AppError(error: $0) })
        }
    }
}

extension DefaultDatabaseManager: FirestoreWorkerDelegate {}

extension DefaultDatabaseManager {
    func getChannels(update: @escaping (Result<[Channel], AppError>) -> Void) {
        chatWorker.getChannels(update: update)
    }

    func getChannelListener(channelId: String, cancel: @escaping (@escaping () -> Void) -> Void,
                            update: @escaping (Result<([Change<Message>], [Message]), AppError>) -> Void) {
        chatWorker.getChannelListener(channelId: channelId, cancel: cancel, update: update)
    }

    func markChannelAsSeen(channel: Channel) {
        chatWorker.markChannelAsSeen(channel: channel)
    }

    func sendMessage(user: User, message: String, toChannel channel: Channel, completion: @escaping (Result<Void, AppError>) -> Void) {
        chatWorker.sendMessage(user: user, message: message, toChannel: channel, completion: completion)
    }

    func getOrCreateChannel(users: [User], completion: @escaping (Result<Channel, AppError>) -> Void) {
        chatWorker.getOrCreateChannel(users: users, completion: completion)
    }
}
