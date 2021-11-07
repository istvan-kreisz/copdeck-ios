//
//  FirestoreWorker.swift
//  CopDeck
//
//  Created by István Kreisz on 11/4/21.
//

import Firebase
import Combine

protocol FirestoreWorker: AnyObject {
    var userId: String? { get }
    var firestore: Firestore { get }

    var errorsSubject: PassthroughSubject<AppError, Never> { get }
    func reset()
    func listenToChanges(userId: String)
}

protocol FirestoreWorkerDelegate: AnyObject {
    var userId: String? { get }
    var firestore: Firestore { get }
    var dbListeners: [FireStoreListener] { get }
}

protocol FirestoreServiceWorker: FirestoreWorker {
    var delegate: FirestoreWorkerDelegate! { get }
    init(delegate: FirestoreWorkerDelegate)
}

extension FirestoreWorker {
    func setDocument(_ data: [String: Any], atRef ref: DocumentReference, using batch: WriteBatch? = nil, updateDates: Bool = true, completion: ((Error?) -> Void)? = nil) {
        let data = updateDates ? dataWithUpdatedDates(data) : data
        if let batch = batch {
            batch.setData(data, forDocument: ref, merge: true)
        } else {
            ref.setData(data, merge: true) { [weak self] error in
                if error != nil {
                    self?.errorsSubject.send(AppError.unknown)
                }
                completion?(error)
            }
        }
    }

//    func updateDocument(_ data: [String: Any], atRef ref: DocumentReference, using batch: WriteBatch? = nil, completion: ((Error?) -> Void)? = nil) {
//        let data = dataWithUpdatedDates(data)
//        if let batch = batch {
//            batch.updateData(data, forDocument: ref)
//        } else {
//            ref.updateData(data) { [weak self] error in
//                if let error = error {
//                    self?.errorsSubject.send(AppError.unknown)
//                }
//                completion?(error)
//            }
//        }
//    }

    func deleteDocument(atRef ref: DocumentReference, using batch: WriteBatch? = nil, completion: ((Error?) -> Void)? = nil) {
        if let batch = batch {
            batch.deleteDocument(ref)
        } else {
            ref.delete { [weak self] error in
                if error != nil {
                    self?.errorsSubject.send(AppError.unknown)
                }
                completion?(error)
            }
        }
    }

    func dataWithUpdatedDates(_ data: [String: Any]) -> [String: Any] {
        var copy = data
        if copy["created"] == nil {
            copy["created"] = Date.serverDate
        }
        copy["updated"] = Date.serverDate
        return copy
    }
}

extension FirestoreServiceWorker {
    var firestore: Firestore { delegate.firestore }
    var userId: String? { delegate.userId }
}
