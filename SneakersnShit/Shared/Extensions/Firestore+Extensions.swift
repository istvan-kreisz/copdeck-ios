//
//  Firestore+Extensions.swift
//  CopDeck
//
//  Created by István Kreisz on 11/4/21.
//

import Firebase

extension CollectionReference {
    func document(_ dbRef: DBRef) -> DocumentReference {
        document(dbRef.rawValue)
    }
}

extension DocumentReference {
    func collection(_ dbRef: DBRef) -> CollectionReference {
        collection(dbRef.rawValue)
    }
}

extension Firestore {
    func collection(_ dbRef: DBRef) -> CollectionReference {
        collection(dbRef.rawValue)
    }
}
