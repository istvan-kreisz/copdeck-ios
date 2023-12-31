//
//  FireStoreListener.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/31/21.
//

import Foundation

protocol FireStoreListener {
    func reset(reinitializePublishers: Bool)
}

extension FireStoreListener {
    func reset() {
        reset(reinitializePublishers: false)
    }
}
