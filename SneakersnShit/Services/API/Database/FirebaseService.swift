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

class FirebaseService: DatabaseManager {
    private let firestore = Firestore.firestore()

    private let inventoryItemsSubject = CurrentValueSubject<[InventoryItem], Never>([])
    private let userSubject = CurrentValueSubject<User?, Never>(nil)
    private let exchangeRatesSubject = PassthroughSubject<ExchangeRates, Never>()
    private let errorsSubject = PassthroughSubject<AppError, Never>()

    var inventoryItemsPublisher: AnyPublisher<[InventoryItem], Never> {
        inventoryItemsSubject.eraseToAnyPublisher()
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

    private var userRef: DocumentReference?
    private var userSettingsRef: DocumentReference?
    private var exchangeRatesRef: DocumentReference?

    private var itemsRef: CollectionReference?
    private var userInventoryRef: CollectionReference?

    private var inventoryListener: ListenerRegistration?
    private var userListener: ListenerRegistration?
    private var exchangeRatesListener: ListenerRegistration?

    private var settings: CopDeckSettings {
        userSubject.value?.settings ?? .default
    }

    init() {
        itemsRef = firestore.collection("items")
        exchangeRatesRef = firestore.collection("info").document("exchangerates")
    }

    func setup(userId: String) {
        userRef = firestore.collection("users").document(userId)
        userInventoryRef = userRef?.collection("inventory")

        listenToChanges()
    }

    private func listenToChanges() {
        stopListening()
        addUserListener()
        addInventoryListener()
        addExchangeRatesListener()
    }

    private func addUserListener() {
        userListener = addDocumentListener(documentRef: userRef, updated: { [weak self] in self?.userSubject.send($0) })
    }

    private func addInventoryListener() {
        inventoryListener = addCollectionListener(collectionRef: userInventoryRef,
                                                  updated: { [weak self] (added: [InventoryItem],
                                                                          removed: [InventoryItem],
                                                                          modified: [InventoryItem]) in
                                                          guard let self = self else { return }
                                                          var newInventoryItems = self.inventoryItemsSubject.value

                                                          newInventoryItems = newInventoryItems
                                                              .filter { element in
                                                                  !removed.contains(where: { $0.id == element.id })
                                                              }
                                                          newInventoryItems.append(contentsOf: added)
                                                          modified.forEach { item in
                                                              if let index = newInventoryItems.firstIndex(where: { $0.id == item.id }) {
                                                                  newInventoryItems[index] = item
                                                              }
                                                          }

                                                          self.inventoryItemsSubject.send(newInventoryItems)
                                                  })
    }

    private func addExchangeRatesListener() {
        exchangeRatesListener = addDocumentListener(documentRef: exchangeRatesRef, updated: { [weak self] in self?.exchangeRatesSubject.send($0) })
    }

    private func addCollectionListener<T: Codable>(collectionRef: CollectionReference?,
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

    func stopListening() {
        inventoryListener?.remove()
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
        Future { [weak self] promise in
            self?.itemsRef?.document(Item.databaseId(itemId: id, settings: settings)).getDocument { snapshot, error in
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
        inventoryItems
            .forEach { inventoryItem in
                _ = (userInventoryRef?.document(inventoryItem.id)).map { batch.deleteDocument($0) }
            }

        batch.commit { [weak self] error in
            if let error = error {
                self?.errorsSubject.send(AppError(error: error))
            }
        }
    }

    func add(exchangeRates: ExchangeRates) {
        if let dict = try? exchangeRates.asDictionary() {
            exchangeRatesRef?.setData(dict) { error in
                if let error = error {
                    print(error)
                }
            }
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

    func update(item: Item, settings: CopDeckSettings) {
        if let dict = try? item.asDictionary() {
            itemsRef?
                .document(item.databaseId(settings: settings))
                .setData(dict, merge: true) { [weak self] error in
                    if let error = error {
                        self?.errorsSubject.send(AppError(error: error))
                    }
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

    func updateUser(user: User) {
        if let dict = try? user.asDictionary() {
            userRef?
                .setData(dict, merge: true) { [weak self] error in
                    if let error = error {
                        self?.errorsSubject.send(AppError(error: error))
                    }
                }
        }
    }

    private func hasSavedItem(withId id: String, completion: @escaping (Bool) -> Void) {
        itemsRef?.document(id).getDocument { snapshot, error in
            completion(snapshot?.exists ?? false)
        }
    }
}
