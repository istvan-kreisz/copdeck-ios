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
        Array(allInventoryItems
            .compactMap { $0.item }
            .reduce([:]) { dict, item in
                dict.merging([item.id: item]) { _, new in new }
            }
            .values)
    }

    private let inventoryItemsSubject = CurrentValueSubject<[InventoryItem], Never>([])
    private let settingsSubject = PassthroughSubject<CopDeckSettings, Never>()
    private let errorsSubject = PassthroughSubject<AppError, Never>()

    var inventoryItemsPublisher: AnyPublisher<[InventoryItem], Never> {
        inventoryItemsSubject.eraseToAnyPublisher()
    }

    var settingsPublisher: AnyPublisher<CopDeckSettings, Never> {
        settingsSubject.eraseToAnyPublisher()
    }

    var errorsPublisher: AnyPublisher<AppError, Never> {
        errorsSubject.eraseToAnyPublisher()
    }

    private var userRef: DocumentReference?
    private var userSettingsRef: DocumentReference?

    private var itemsRef: CollectionReference?
    private var userInventoryRef: CollectionReference?
    private var sneakersRef: CollectionReference?

    private var inventoryListener: ListenerRegistration?
    private var settingsListener: ListenerRegistration?
    private var itemsListeners: [String: ListenerRegistration] = [:]

    func setup(userId: String) {
        userRef = firestore.collection("users").document(userId)
        userSettingsRef = userRef?.collection("userinfo").document("settings")

        itemsRef = firestore.collection("items")
        userInventoryRef = userRef?.collection("inventory")
        sneakersRef = firestore.collection("sneakers")

        listenToChanges(userId: userId)
    }

    func listenToChanges(userId: String) {
        addInventoryListener()
        addSettingsListener()
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

    private func addSettingsListener() {
        settingsListener = addDocumentListener(documentRef: userSettingsRef, updated: { [weak self] (settings: CopDeckSettings) in
            self?.settingsSubject.send(settings)
        })
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
        settingsListener?.remove()
        itemsListeners.values.forEach { $0.remove() }
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
}
