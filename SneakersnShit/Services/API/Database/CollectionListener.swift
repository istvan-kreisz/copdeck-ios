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
    let dataSubject = CurrentValueSubject<[T], Never>([])

    var dataPublisher: AnyPublisher<[T], Never> {
        dataSubject.eraseToAnyPublisher()
    }

    func startListening(collectionName: String, baseDocumentReference: DocumentReference?) {
        collectionRef = baseDocumentReference?.collection(collectionName)
        listener = addCollectionListener(collectionRef: collectionRef) { [weak self] in
            self?.dataSubject.send($0)
        }
    }

    func reset() {
        listener?.remove()
    }

    private func addCollectionListener(collectionRef: CollectionReference?, updated: @escaping (_ items: [T]) -> Void) -> ListenerRegistration? {
        collectionRef?
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching documents: \(error)")
                    return
                }
                updated(snapshot?.documents.compactMap { T(from: $0.data()) } ?? [])
            }
    }
}
