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
    var collectionRef: CollectionReference?
    var listener: ListenerRegistration?
    let dataSubject = CurrentValueSubject<[T], AppError>([])
    var value: [T] { dataSubject.value }

    var dataPublisher: AnyPublisher<[T], AppError> {
        dataSubject.eraseToAnyPublisher()
    }

    func startListening(collectionName: String, baseDocumentReference: DocumentReference?, query: ((CollectionReference?) -> Query?)? = nil) {
        collectionRef = baseDocumentReference?.collection(collectionName)
        listener = addCollectionListener(collectionRef: collectionRef, query: query) { [weak self] in
            self?.dataSubject.send($0)
        }
    }
    
    func startListening(collectionName: String, firestore: Firestore?, query: ((CollectionReference?) -> Query?)? = nil) {
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
        updated(snapshot?.documents.compactMap { T(from: $0.data()) } ?? [])
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
