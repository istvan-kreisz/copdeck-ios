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

    var allInventoryItems: [InventoryItem] {
        inventoryItemsSubject.value
    }

    var allItems: [Item] {
        allInventoryItems.allItems
    }

    private let inventoryItemsSubject = CurrentValueSubject<[InventoryItem], Never>([])
    private let userSubject = PassthroughSubject<User, Never>()
    private let exchangeRatesSubject = PassthroughSubject<ExchangeRates, Never>()
    private let errorsSubject = PassthroughSubject<AppError, Never>()

    var inventoryItemsPublisher: AnyPublisher<[InventoryItem], Never> {
        inventoryItemsSubject.eraseToAnyPublisher()
    }

    var userPublisher: AnyPublisher<User, Never> {
        userSubject.eraseToAnyPublisher()
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
    private var itemsListeners: [String: ListenerRegistration] = [:]

    init() {
        itemsRef = firestore.collection("items")
        userInventoryRef = userRef?.collection("inventory")
        exchangeRatesRef = firestore.collection("info").document("exchangerates")

        addExchangeRatesListener()
    }

    func setup(userId: String) {
        userRef = firestore.collection("users").document(userId)
        listenToChanges()
    }

    private func listenToChanges() {
        stopListening()
        addUserListener()
        addInventoryListener()
    }

    private func addUserListener() {
        userListener = addDocumentListener(documentRef: userRef, updated: { [weak self] in self?.userSubject.send($0) })
    }

    private func addInventoryListener() {
        inventoryListener = addCollectionListener(collectionRef: userInventoryRef,
                                                  updated: { [weak self] (all: [InventoryItem],
                                                                          added: [InventoryItem],
                                                                          removed: [InventoryItem],
                                                                          modified: [InventoryItem]) in
                                                          guard let self = self else { return }
                                                          added.forEach { [weak self] inventoryItem in
                                                              self?.addItemListener(for: inventoryItem.id)
                                                          }
                                                          removed.forEach { [weak self] inventoryItem in
                                                              self?.removeItemListener(for: inventoryItem.id)
                                                          }

                                                          let newInventoryItems = all.map { new -> InventoryItem in
                                                              new.copy(with: self.allItems.first(where: { $0.id == new.itemId }))
                                                          }
                                                          self.inventoryItemsSubject.send(newInventoryItems)
                                                  })
    }

    private func addExchangeRatesListener() {
        exchangeRatesListener = addDocumentListener(documentRef: exchangeRatesRef, updated: { [weak self] in self?.exchangeRatesSubject.send($0) })
    }

    private func addItemListener(for itemId: String) {
        guard itemsListeners[itemId] == nil else { return }
        itemsListeners[itemId] = addDocumentListener(documentRef: itemsRef?.document(itemId),
                                                     updated: { [weak self] (item: Item) in
                                                         guard let self = self else { return }
                                                         let newInventoryItems = self.allInventoryItems.map { new -> InventoryItem in
                                                             new.itemId == itemId ? new.copy(with: item) : new
                                                         }
                                                         self.inventoryItemsSubject.send(newInventoryItems)
                                                     })
    }

    private func removeItemListener(for itemId: String) {
        itemsListeners[itemId]?.remove()
        itemsListeners[itemId] = nil
    }

    private func addCollectionListener<T: Codable>(collectionRef: CollectionReference?,
                                                   updated: @escaping (_ all: [T], _ added: [T], _ removed: [T], _ modified: [T]) -> Void)
        -> ListenerRegistration? {
        collectionRef?
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching documents: \(error)")
                    return
                }
                var all: [T] = []
                var added: [T] = []
                var modified: [T] = []
                var removed: [T] = []
                snapshot?.documentChanges.forEach { diff in
                    let dict = diff.document.data()
                    guard let element = T(from: dict) else { return }
                    switch diff.type {
                    case .added:
                        all.append(element)
                        added.append(element)
                    case .modified:
                        all.append(element)
                        modified.append(element)
                    case .removed:
                        removed.append(element)
                    }
                }
                updated(all, added, removed, modified)
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
        itemsListeners.values.forEach { $0.remove() }
    }

    func getUser(withId id: String) -> AnyPublisher<User, AppError> {
        Future { [weak self] promise in
            self?.firestore.collection("users").document(id).getDocument { snapshot, error in
                if let dict = snapshot?.data(), let user = User(from: dict) {
                    promise(.success(user))
                } else if let error = error {
                    promise(.failure(AppError(error: error)))
                } else {
                    promise(.success(User(id: id)))
                }
            }
        }.eraseToAnyPublisher()
    }

    func delete(inventoryItem: InventoryItem) {
        userInventoryRef?
            .document(inventoryItem.id)
            .delete { [weak self] error in
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
        let savedItems = allItems
        let newItems = inventoryItems.allItems.filter { item in
            !savedItems.contains(where: { $0.id == item.id })
        }

        // add inventory items
        let batch = firestore.batch()
        inventoryItems
            .compactMap { inventoryItem -> (String, [String: Any])? in
                if let dict = try? inventoryItem.asDictionary() {
                    return (inventoryItem.id, dict)
                } else {
                    return nil
                }
            }
            .forEach { id, dict in
                if let inventoryItemRef = userInventoryRef?.document(id) {
                    batch.setData(dict, forDocument: inventoryItemRef)
                }
            }

        newItems
            .compactMap { item -> (String, [String: Any])? in
                if let dict = try? item.asDictionary() {
                    return (item.id, dict)
                } else {
                    return nil
                }
            }
            .forEach { id, dict in
                if let itemRef = itemsRef?.document(id) {
                    batch.setData(dict, forDocument: itemRef)
                }
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

    func updateSettings(settings: CopDeckSettings) {
        if let dict = try? settings.asDictionary() {
            userSettingsRef?
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
