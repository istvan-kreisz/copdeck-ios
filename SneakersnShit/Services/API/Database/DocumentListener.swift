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

#warning("handle errors")

class DocumentListener<T: Codable>: FireStoreListener {
    var documentRef: DocumentReference?
    var listener: ListenerRegistration?
    let dataSubject = CurrentValueSubject<T?, Never>(nil)

    var dataPublisher: AnyPublisher<T?, Never> {
        dataSubject.eraseToAnyPublisher()
    }

    func startListening(documentRef: DocumentReference?) {
        self.documentRef = documentRef
        listener = addDocumentListener(documentRef: documentRef) { [weak self] in
            self?.dataSubject.send($0)
        }
    }

    func reset() {
        listener?.remove()
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
                }
            }
    }
}
