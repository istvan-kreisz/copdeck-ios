//
//  DocumentListener.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/31/21.
//

import Firebase
import Combine
import UIKit
import FirebaseStorage

class DocumentListener<T: Codable>: FireStoreListener {
    var documentRef: DocumentReference?
    var listener: ListenerRegistration?
    var dataSubject = CurrentValueSubject<T?, AppError>(nil)

    var dataPublisher: AnyPublisher<T?, AppError> {
        dataSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func startListening(documentRef: DocumentReference?, updated: ((T) -> Void)? = nil) {
        self.documentRef = documentRef
        if let updated = updated {
            listener = addDocumentListener(documentRef: documentRef, updated: updated)
        } else {
            listener = addDocumentListener(documentRef: documentRef) { [weak self] in
                self?.dataSubject.send($0)
            }
        }
    }

    func reset(reinitializePublishers: Bool = false) {
        if reinitializePublishers {
            dataSubject = CurrentValueSubject<T?, AppError>(nil)
        }
        listener?.remove()
    }

    private func addDocumentListener<T: Codable>(documentRef: DocumentReference?, updated: @escaping (T) -> Void) -> ListenerRegistration? {
        documentRef?
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    log("Error fetching document: \(error)")
                    return
                }
                if let document = snapshot?.data(), let result = T(from: document) {
                    updated(result)
                }
            }
    }
}
