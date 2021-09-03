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
import FirebaseStorage

#warning("better error handling for image downloads")

class FirebaseService: DatabaseManager {
    private static let recentlyViewedLimit = 20

    private let firestore: Firestore
    private let storage: Storage

    private var userId: String?

    private var feedLastDocument: QueryDocumentSnapshot?

    // collection listeners
    private var inventoryListener = CollectionListener<InventoryItem>()
    private var stacksListener = CollectionListener<Stack>()
    private var favoritesListener = CollectionListener<Item>()
    private var recentlyViewedListener = CollectionListener<Item>()

    // document listeners
    private var userListener = DocumentListener<User>()
    private var exchangeRatesListener = DocumentListener<ExchangeRates>()

    private let errorsSubject = PassthroughSubject<AppError, Never>()
    private let popularItemsSubject = PassthroughSubject<[Item], Never>()
    private let imageSubject = CurrentValueSubject<URL?, Never>(nil)

    private var dbListeners: [FireStoreListener] {
        let listeners: [FireStoreListener?] = [inventoryListener,
                                               stacksListener,
                                               favoritesListener,
                                               recentlyViewedListener,
                                               userListener,
                                               exchangeRatesListener]
        return listeners.compactMap { $0 }
    }

    var imageURL: URL? {
        imageSubject.value
    }

    // collection publishers
    var inventoryItemsPublisher: AnyPublisher<[InventoryItem], Never> {
        inventoryListener.dataPublisher
    }

    var favoritesPublisher: AnyPublisher<[Item], Never> {
        favoritesListener.dataPublisher
    }

    var recentlyViewedPublisher: AnyPublisher<[Item], Never> {
        recentlyViewedListener.dataPublisher
    }

    var stacksPublisher: AnyPublisher<[Stack], Never> {
        stacksListener.dataPublisher
    }

    // document publishers
    var userPublisher: AnyPublisher<User, Never> {
        userListener.dataPublisher.compactMap { $0 }.eraseToAnyPublisher()
    }

    var exchangeRatesPublisher: AnyPublisher<ExchangeRates, Never> {
        exchangeRatesListener.dataPublisher.compactMap { $0 }.eraseToAnyPublisher()
    }

    var errorsPublisher: AnyPublisher<AppError, Never> {
        errorsSubject.eraseToAnyPublisher()
    }

    var popularItemsPublisher: AnyPublisher<[Item], Never> {
        popularItemsSubject.eraseToAnyPublisher()
    }

    var profileImagePublisher: AnyPublisher<URL?, Never> {
        imageSubject.eraseToAnyPublisher()
    }

    private var itemsRef: CollectionReference?

    private var imageRef: StorageReference?
    private var uploadTask: StorageUploadTask?

    init() {
        firestore = Firestore.firestore()
        storage = Storage.storage()
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

        imageRef = storage.reference().child("images/\(userId)/profilePicture.jpg")
        self.userId = userId

        reset()
        listenToChanges(userId: userId)
        getUserProfileImage()
    }

    private func listenToChanges(userId: String) {
        userListener.startListening(documentRef: firestore.collection("users").document(userId))
        inventoryListener.startListening(collectionName: "inventory", baseDocumentReference: userListener.documentRef)
        stacksListener.startListening(collectionName: "stacks", baseDocumentReference: userListener.documentRef)
        favoritesListener.startListening(collectionName: "favorites", baseDocumentReference: userListener.documentRef)
        recentlyViewedListener.startListening(collectionName: "recentlyViewed", baseDocumentReference: userListener.documentRef)
    }

    func getImageURLs(for users: [User]) -> AnyPublisher<[User], AppError> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.success([]))
                return
            }
            var usersWithImageURLs: [User] = []
            let dispatchGroup = DispatchGroup()
            for user in users {
                dispatchGroup.enter()
                let imageRef = self.storage.reference().child("images/\(user.id)/profilePicture.jpg")
                self.getProfileImage(at: imageRef) { url, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            log("error downloading image \(error)")
                            usersWithImageURLs.append(user)
                        } else {
                            var copy = user
                            copy.imageURL = url
                            usersWithImageURLs.append(copy)
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.notify(queue: .main) {
                promise(.success(usersWithImageURLs))
            }
        }.eraseToAnyPublisher()
    }

    private func getUserProfileImage() {
        getProfileImage(at: imageRef) { [weak self] url, error in
            if let error = error {
                log("error downloading image \(error)")
            } else {
                self?.imageSubject.send(url)
            }
        }
    }

    private func getProfileImage(at storageRef: StorageReference?, completion: @escaping (URL?, Error?) -> Void) {
        storageRef?.downloadURL(completion: completion)
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
                log("db read itemId: \(id)")
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
                _ = (inventoryListener.collectionRef?.document(inventoryItem.id)).map { batch.deleteDocument($0) }
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
                    .map { ref in
                        if let data = try? stack.asDictionary() {
                            batch.updateData(data, forDocument: ref)
                        }
                    }
            }

        batch.commit { [weak self] error in
            if let error = error {
                self?.errorsSubject.send(AppError(error: error))
            }
        }
    }

    func update(stack: Stack) {
        var updatedStack = stack
        if updatedStack.isPublished ?? false, updatedStack.publishedDate == nil {
            updatedStack.publishedDate = Date().timeIntervalSince1970 * 1000
        }
        if let dict = try? updatedStack.asDictionary() {
            stacksListener.collectionRef?
                .document(updatedStack.id)
                .setData(dict, merge: true) { [weak self] error in
                    if let error = error {
                        self?.errorsSubject.send(AppError(error: error))
                    }
                }
        }
    }

    func delete(stack: Stack) {
        stacksListener.collectionRef?
            .document(stack.id)
            .delete { [weak self] error in
                error.map { self?.errorsSubject.send(AppError(error: $0)) }
            }
    }

    func add(inventoryItems: [InventoryItem]) {
        let batch = firestore.batch()
        inventoryItems
            .compactMap { inventoryItem -> (String, [String: Any])? in
                (try? inventoryItem.asDictionary()).map { (inventoryItem.id, $0) } ?? nil
            }
            .forEach { id, dict in
                _ = (inventoryListener.collectionRef?.document(id)).map { batch.setData(dict, forDocument: $0, merge: true) }
            }

        batch.commit { [weak self] error in
            if let error = error {
                self?.errorsSubject.send(AppError(error: error))
            }
        }
    }

    func update(inventoryItem: InventoryItem) {
        if let dict = try? inventoryItem.asDictionary() {
            inventoryListener.collectionRef?
                .document(inventoryItem.id)
                .setData(dict, merge: true) { [weak self] error in
                    if let error = error {
                        self?.errorsSubject.send(AppError(error: error))
                    }
                }
        }
    }

    func update(user: User) {
        if let dict = try? user.asDictionary() {
            userListener.documentRef?
                .setData(dict, merge: true) { [weak self] error in
                    if let error = error {
                        self?.errorsSubject.send(AppError(error: error))
                    }
                }
        }
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
            deletedDocRefs.forEach { batch.deleteDocument($0) }
        }
        // add new
        log("add new recentlyViewedItem \(recentlyViewedItem.id)")
        if let dict = try? recentlyViewedItem.strippedOfPrices.asDictionary() {
            if let newDocumentRef = recentlyViewedListener.collectionRef?.document(Item.databaseId(itemId: recentlyViewedItem.id, settings: nil)) {
                batch.setData(dict, forDocument: newDocumentRef, merge: true)
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
        if let dict = try? item.strippedOfPrices.asDictionary() {
            favoritesListener.collectionRef?
                .document(Item.databaseId(itemId: item.id, settings: nil)).setData(dict) { [weak self] error in
                    if let error = error {
                        self?.errorsSubject.send(AppError(error: error))
                    }
                }
        }
    }

    func unfavorite(item: Item) {
        favoritesListener.collectionRef?.document(Item.databaseId(itemId: item.id, settings: nil)).delete { [weak self] error in
            if let error = error {
                self?.errorsSubject.send(AppError(error: error))
            }
        }
    }

    func uploadProfileImage(image: UIImage) {
        guard let data = image.resizeImage(300).jpegData(compressionQuality: 0.4),
              let imageRef = imageRef
        else { return }
        uploadTask?.cancel()

        imageRef.listAll { [weak self] result, error in
            if result.items.isEmpty {
                self?.uploadImageData(data)
            } else {
                imageRef.delete { error in
                    if let error = error {
                        self?.uploadImageData(data)
                    } else {
                        self?.uploadImageData(data)
                    }
                }
            }
        }
    }

    private func uploadImageData(_ data: Data) {
        uploadTask = imageRef?.putData(data, metadata: nil) { [weak self] metadata, error in
            self?.getUserProfileImage()
        }
    }
}
