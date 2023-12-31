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
    func getCollection<T: Codable>(atRef ref: CollectionReference, completion: @escaping (Result<[T], Error>) -> Void) {
        ref.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let elements = snapshot?.documents.compactMap({ T(from: $0.data()) }) {
                    completion(.success(elements))
                } else {
                    completion(.failure(AppError.unknown))
                }
            }
        }
    }

    func getDocument<T: Codable>(atRef ref: DocumentReference, completion: @escaping (Result<T, Error>) -> Void) {
        ref.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let data = snapshot?.data(), let result = T(from: data) {
                    completion(.success(result))
                } else {
                    completion(.failure(AppError.unknown))
                }
            }
        }
    }

    func setDocument(_ data: [String: Any], atRef ref: DocumentReference, merge: Bool, using batch: WriteBatch? = nil, updateDates: Bool = true,
                     completion: ((Error?) -> Void)? = nil) {
        let data = updateDates ? dataWithUpdatedDates(data) : data
        if let batch = batch {
            batch.setData(data, forDocument: ref, merge: merge)
        } else {
            ref.setData(data, merge: merge) { [weak self] error in
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
