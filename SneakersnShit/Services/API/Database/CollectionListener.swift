//
//  CollectionListener.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/31/21.
//

import Firebase
import Combine
import UIKit
import FirebaseStorage

class CollectionListener<T: Codable>: FireStoreListener {
    enum UpdateType {
        case data, changes
    }

    enum Change {
        case add(T)
        case update(T)
        case delete(T)
    }

    var collectionRef: CollectionReference?
    var listener: ListenerRegistration?
    var updateType: UpdateType = .data
    let dataSubject = CurrentValueSubject<[T], AppError>([])
    let changesSubject = CurrentValueSubject<[Change], AppError>([])
    var value: [T] { dataSubject.value }

    var dataPublisher: AnyPublisher<[T], AppError> {
        dataSubject.eraseToAnyPublisher()
    }

    var changesPublisher: AnyPublisher<[Change], AppError> {
        changesSubject.eraseToAnyPublisher()
    }

    func startListening(updateType: UpdateType = .data, collectionName: String, baseDocumentReference: DocumentReference?,
                        query: ((CollectionReference?) -> Query?)? = nil) {
        self.updateType = updateType
        collectionRef = baseDocumentReference?.collection(collectionName)
        listener = addCollectionListener(collectionRef: collectionRef, query: query) { [weak self] in
            self?.dataSubject.send($0)
        }
    }

    func startListening(updateType: UpdateType = .data, collectionName: String, firestore: Firestore?, query: ((CollectionReference?) -> Query?)? = nil) {
        self.updateType = updateType
        collectionRef = firestore?.collection(collectionName)
        listener = addCollectionListener(collectionRef: collectionRef, query: query) { [weak self] in
            self?.dataSubject.send($0)
        }
    }

    func reset() {
        listener?.remove()
    }

    private func handleResult(snapshot: QuerySnapshot?, error: Error?, updated: @escaping (_ items: [T]) -> Void) {
        if let error = error {
            print("Error fetching documents: \(error)")
            return
        }
        switch updateType {
        case .data:
            updated(snapshot?.documents.compactMap { T(from: $0.data()) } ?? [])
        case .changes:
            var changes: [Change] = []
            snapshot?.documentChanges.forEach { diff in
                let dict = diff.document.data()
                guard let element = T(from: dict) else { return }
                switch diff.type {
                case .added:
                    changes.append(.add(element))
                case .modified:
                    changes.append(.update(element))
                case .removed:
                    changes.append(.delete(element))
                }
            }
            changesSubject.send(changes)
        }
    }

    private func addCollectionListener(collectionRef: CollectionReference?,
                                       query: ((CollectionReference?) -> Query?)? = nil,
                                       updated: @escaping (_ items: [T]) -> Void) -> ListenerRegistration? {
        if let query = query {
            return query(collectionRef)?.addSnapshotListener { [weak self] snapshot, error in
                self?.handleResult(snapshot: snapshot, error: error, updated: updated)
            }
        } else {
            return collectionRef?
                .addSnapshotListener { [weak self] snapshot, error in
                    self?.handleResult(snapshot: snapshot, error: error, updated: updated)
                }
        }
    }
}
