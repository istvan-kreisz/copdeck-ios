//
//  FirebaseService.swift
//  CopDeck
//
//  Created by István Kreisz on 4/7/20.
//  Copyright © 2020 István Kreisz. All rights reserved.
//

import Foundation
import Firebase
import Combine
import UIKit
import FirebaseStorage

#warning("better error handling for image downloads")

class FirebaseService: DatabaseManager {
    private let firestore: Firestore
    private let storage: Storage

    private var userId: String?

    private let inventoryItemsSubject = CurrentValueSubject<[InventoryItem], Never>([])
    private let stacksSubject = CurrentValueSubject<[Stack], Never>([])
    private let userSubject = CurrentValueSubject<User?, Never>(nil)
    private let exchangeRatesSubject = PassthroughSubject<ExchangeRates, Never>()
    private let errorsSubject = PassthroughSubject<AppError, Never>()
    private let popularItemsSubject = PassthroughSubject<[Item], Never>()
    private let imageSubject = CurrentValueSubject<URL?, Never>(nil)

    var imageURL: URL? {
        imageSubject.value
    }

    var profileImagePublisher: AnyPublisher<URL?, Never> {
        imageSubject.eraseToAnyPublisher()
    }

    var inventoryItemsPublisher: AnyPublisher<[InventoryItem], Never> {
        inventoryItemsSubject.eraseToAnyPublisher()
    }

    var stacksPublisher: AnyPublisher<[Stack], Never> {
        stacksSubject.eraseToAnyPublisher()
    }

    var userPublisher: AnyPublisher<User, Never> {
        userSubject.compactMap { $0 }.eraseToAnyPublisher()
    }

    var exchangeRatesPublisher: AnyPublisher<ExchangeRates, Never> {
        exchangeRatesSubject.eraseToAnyPublisher()
    }

    var errorsPublisher: AnyPublisher<AppError, Never> {
        errorsSubject.eraseToAnyPublisher()
    }

    var popularItemsPublisher: AnyPublisher<[Item], Never> {
        popularItemsSubject.eraseToAnyPublisher()
    }

    private var userRef: DocumentReference?
    private var userSettingsRef: DocumentReference?
    private var exchangeRatesRef: DocumentReference?

    private var itemsRef: CollectionReference?
    private var userInventoryRef: CollectionReference?
    private var userStacksRef: CollectionReference?

    private var inventoryListener: ListenerRegistration?
    private var stacksListener: ListenerRegistration?
    private var userListener: ListenerRegistration?
    private var exchangeRatesListener: ListenerRegistration?

    private var imageRef: StorageReference?
    private var uploadTask: StorageUploadTask?

    private var settings: CopDeckSettings {
        userSubject.value?.settings ?? .default
    }

    init() {
        firestore = Firestore.firestore()
        storage = Storage.storage()
        let settings = firestore.settings
        settings.cacheSizeBytes = 200 * 1_000_000
        if DebugSettings.shared.isInDebugMode, DebugSettings.shared.useFunctionsEmulator {
            settings.host = "192.168.0.199:8080"
            settings.isPersistenceEnabled = false
            settings.isSSLEnabled = false
        }
        firestore.settings = settings

        itemsRef = firestore.collection("items")
        exchangeRatesRef = firestore.collection("info").document("exchangerates")
    }

    func setup(userId: String) {
        guard userId != self.userId else { return }
        userRef = firestore.collection("users").document(userId)
        userInventoryRef = userRef?.collection("inventory")
        userStacksRef = userRef?.collection("stacks")

        imageRef = storage.reference().child("images/\(userId)/profilePicture.jpg")

        self.userId = userId

        listenToChanges()
        getProfileImage()
    }

    private func listenToChanges() {
        reset()
        addUserListener()
        addInventoryListener()
        addStacksListener()
        addExchangeRatesListener()
    }

    private func getProfileImage() {
        imageRef?.downloadURL { [weak self] url, error in
            if let error = error {
                log(error)
            } else {
                self?.imageSubject.send(url)
            }
        }
    }

    private func addUserListener() {
        userListener = addDocumentListener(documentRef: userRef, updated: { [weak self] in self?.userSubject.send($0) })
    }

    private func addInventoryListener() {
        inventoryListener = addCollectionListener(collectionRef: userInventoryRef) { [weak self] in
            self?.inventoryItemsSubject.send($0)
        }
    }

    private func addStacksListener() {
        stacksListener = addCollectionListener(collectionRef: userStacksRef) { [weak self] in
            self?.stacksSubject.send($0)
        }
    }

    private func addExchangeRatesListener() {
        exchangeRatesListener = addDocumentListener(documentRef: exchangeRatesRef, updated: { [weak self] in self?.exchangeRatesSubject.send($0) })
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

    private func addCollectionListener<T: Codable>(collectionRef: CollectionReference?, updated: @escaping (_ items: [T]) -> Void)
        -> ListenerRegistration? {
        collectionRef?
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching documents: \(error)")
                    return
                }
                updated(snapshot?.documents.compactMap { T(from: $0.data()) } ?? [])
            }
    }

    private func addDocumentListener<T: Codable>(documentRef: DocumentReference?, updated: @escaping (T) -> Void) -> ListenerRegistration? {
        documentRef?
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    self?.errorsSubject.send(AppError(error: error))
                    return
                }
                if let document = snapshot?.data(), let result = T(from: document) {
                    updated(result)
                }
            }
    }

    func reset() {
        inventoryListener?.remove()
        stacksListener?.remove()
        userListener?.remove()
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
                _ = (userInventoryRef?.document(inventoryItem.id)).map { batch.deleteDocument($0) }
            }
        // update stacks
        stacksSubject
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
                _ = (userStacksRef?.document(stack.id))
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
        if let dict = try? stack.asDictionary() {
            userStacksRef?
                .document(stack.id)
                .setData(dict, merge: true) { [weak self] error in
                    if let error = error {
                        self?.errorsSubject.send(AppError(error: error))
                    }
                }
        }
    }

    func delete(stack: Stack) {
        userStacksRef?
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
                _ = (userInventoryRef?.document(id)).map { batch.setData(dict, forDocument: $0, merge: true) }
            }

        batch.commit { [weak self] error in
            if let error = error {
                self?.errorsSubject.send(AppError(error: error))
            }
        }
    }

    func update(inventoryItem: InventoryItem) {
        if let dict = try? inventoryItem.asDictionary() {
            userInventoryRef?
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
            userRef?
                .setData(dict, merge: true) { [weak self] error in
                    if let error = error {
                        self?.errorsSubject.send(AppError(error: error))
                    }
                }
        }
    }

    func uploadProfileImage(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.2),
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
            self?.getProfileImage()
        }
    }
}
