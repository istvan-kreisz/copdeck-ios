//
//  FirebaseService.swift
//  CopDeck
//
//  Created by István Kreisz on 4/7/20.
//  Copyright © 2020 István Kreisz. All rights reserved.
//

import Foundation
import Firebase

class FirebaseService: DatabaseManager {
    private let firestore = Firestore.firestore()

    private var userRef: DocumentReference?
    private var userSettingsRef: DocumentReference?
    private var userInventoryRef: CollectionReference?
    private var sneakersRef: CollectionReference?

    private var inventoryListener: ListenerRegistration?
    private var settingsListener: ListenerRegistration?
//    private var settingsListener: ListenerRegistration?

    private weak var delegate: DatabaseManagerDelegate?

    func setup(userId: String, delegate: DatabaseManagerDelegate?) {
        self.delegate = delegate
        userRef = firestore.collection("users").document(userId)
        userSettingsRef = userRef?.collection("userinfo").document("settings")
        userInventoryRef = userRef?.collection("inventory")
        sneakersRef = firestore.collection("sneakers")
        listenToChanges(userId: userId)
    }

    func listenToChanges(userId: String) {
        inventoryListener = addCollectionListener(collectionRef: userInventoryRef,
                                                  updated: { [weak self] (all: [InventoryItem],
                                                                          sadded: [InventoryItem],
                                                                          removed: [InventoryItem],
                                                                          modified: [InventoryItem]) in
                                                          self?.delegate?.updatedInventoryItems(newInventoryItems: all)
                                                  })
        settingsListener = addDocumentListener(documentRef: userSettingsRef, updated: { [weak self] (settings: CopDeckSettings) in
            self?.delegate?.updatedSettings(newSettings: settings)
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
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching document: \(error)")
                    return
                }
                if let document = snapshot?.data(), let result = T(from: document) {
                    updated(result)
                } else {
                    #warning("now what?")
                }
            }
    }

    func stopListening() {
        inventoryListener?.remove()
        settingsListener?.remove()
    }

    func delete(inventoryItem: InventoryItem) {
        userInventoryRef?
            .document(inventoryItem.id)
            .delete { [weak self] error in
                if let error = error {
                    #warning("todo")
                } else {
                    #warning("todo")
                }
            }
    }

    func update(inventoryItem: InventoryItem) {
        if let dict = try? inventoryItem.asDictionary() {
            userInventoryRef?
                .document(inventoryItem.id)
                .setData(dict, merge: true) { [weak self] error in
                    if let error = error {
                        #warning("todo")
                    } else {
                        #warning("todo")
                    }
                }
        }
    }

    func updateSettings(settings: CopDeckSettings) {
        if let dict = try? settings.asDictionary() {
            userSettingsRef?
                .setData(dict, merge: true) { [weak self] error in
                    if let error = error {
                        #warning("todo")
                    } else {
                        #warning("todo")
                    }
                }
        }
    }
}
