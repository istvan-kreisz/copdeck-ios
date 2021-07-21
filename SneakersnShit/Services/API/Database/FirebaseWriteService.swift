//
//  FirebaseWriteService.swift
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
    private var userInventoryRef: CollectionReference?
    private var userSettingsRef: CollectionReference?
    private var sneakersRef: CollectionReference?

    private var inventoryListener: ListenerRegistration?
    private var settingsListener: ListenerRegistration?
//    private var settingsListener: ListenerRegistration?

    private weak var delegate: DatabaseManagerDelegate?

    func setup(userId: String, delegate: DatabaseManagerDelegate?) {
        self.delegate = delegate
        userRef = firestore.collection("users").document(userId)
        userInventoryRef = userRef?.collection("inventory")
        userSettingsRef = userRef?.collection("settings")
        sneakersRef = firestore.collection("sneakers")
        listenToChanges(userId: userId)
    }

    func listenToChanges(userId: String) {
        inventoryListener = addCollectionListener(collectionRef: userInventoryRef, updated: { [weak self] (inventoryItems: [InventoryItem]) in
            self?.delegate?.updatedInventoryItems(newInventoryItems: inventoryItems)
        })
//        inventoryListener = addListener(collectionRef: userInventoryRef, updated: { [weak self] (inventoryItems: [InventoryItem]) in
//            self?.delegate?.updatedInventoryItems(newInventoryItems: inventoryItems)
//        })
    }

    private func addCollectionListener<T: Codable>(collectionRef: CollectionReference?, updated: @escaping ([T]) -> Void) -> ListenerRegistration? {
        collectionRef?
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching documents: \(error)")
                    return
                }
                let elements = (snapshot?.documents ?? []).compactMap { doc in
                    T(from: doc.data())
                }
                updated(elements)
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

    func add(inventoryItem: InventoryItem) {
        if let dict = try? inventoryItem.asDictionary() {
            userInventoryRef?
                .document(inventoryItem.id)
                .setData(dict) { [weak self] error in
                    if let error = error {
                        #warning("todo")
                    } else {
                        #warning("todo")
                    }
                }
        }
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
                .updateData(dict) { [weak self] error in
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
                .document("settings")
                .updateData(dict) { [weak self] error in
                    if let error = error {
                        #warning("todo")
                    } else {
                        #warning("todo")
                    }
                }
        }
    }
}
