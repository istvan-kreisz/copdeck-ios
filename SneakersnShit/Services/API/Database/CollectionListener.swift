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

enum Change<T: Codable> {
    case add(T)
    case update(T)
    case delete(T)
}

class CollectionListener<T: Codable & Equatable>: FireStoreListener {
    enum UpdateType {
        case data, changes
    }

    var collectionRef: CollectionReference?
    var listener: ListenerRegistration?
    var updateType: UpdateType = .data
    var dataSubject = CurrentValueSubject<[T], AppError>([])
    var changesSubject = CurrentValueSubject<([Change<T>], [T]), AppError>(([], []))
    var value: [T] { dataSubject.value }

    var dataPublisher: AnyPublisher<[T], AppError> {
        dataSubject.dropFirst().eraseToAnyPublisher()
    }

    var changesPublisher: AnyPublisher<([Change<T>], [T]), AppError> {
        changesSubject.dropFirst().eraseToAnyPublisher()
    }

    func startListening(updateType: UpdateType = .data, collectionName: String, baseDocumentReference: DocumentReference?,
                        query: ((CollectionReference?) -> Query?)? = nil) {
        self.updateType = updateType
        collectionRef = baseDocumentReference?.collection(collectionName)
        listener = addCollectionListener(collectionRef: collectionRef, query: query)
    }

    func startListening(updateType: UpdateType = .data, collectionName: String, firestore: Firestore?, query: ((CollectionReference?) -> Query?)? = nil) {
        self.updateType = updateType
        collectionRef = firestore?.collection(collectionName)
        listener = addCollectionListener(collectionRef: collectionRef, query: query)
    }

    func reset(reinitializePublishers: Bool = false) {
        if reinitializePublishers {
            dataSubject = CurrentValueSubject<[T], AppError>([])
            changesSubject = CurrentValueSubject<([Change<T>], [T]), AppError>(([], []))
        }
        listener?.remove()
    }

    private func handleResult(snapshot: QuerySnapshot?, error: Error?) {
        if let error = error {
            print("Error fetching documents: \(error)")
            return
        }
        let updatedData = snapshot?.documents.compactMap { T(from: $0.data()) } ?? []
        
        switch updateType {
        case .data:
            dataSubject.send(updatedData)
        case .changes:
            var changes: [Change<T>] = []
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
            changesSubject.send((changes, updatedData))
        }
    }

    private func addCollectionListener(collectionRef: CollectionReference?, query: ((CollectionReference?) -> Query?)? = nil) -> ListenerRegistration? {
        if let query = query {
            return query(collectionRef)?.addSnapshotListener { [weak self] snapshot, error in
                self?.handleResult(snapshot: snapshot, error: error)
            }
        } else {
            return collectionRef?.addSnapshotListener { [weak self] snapshot, error in
                self?.handleResult(snapshot: snapshot, error: error)
            }
        }
    }
}
