//
//  Cache.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/17/21.
//

import Foundation
import Combine

final class Cache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let entryLifetime: TimeInterval

    private let updatedSubject = PassthroughSubject<Void, Never>()
    lazy var updatedPublisher = updatedSubject.eraseToAnyPublisher()

    init(entryLifetimeMin: TimeInterval) {
        self.entryLifetime = entryLifetimeMin * 60
    }

    func insert(_ value: Value, forKey key: Key) {
        let date = Date().addingTimeInterval(entryLifetime)
        let entry = Entry(value: value, expirationDate: date)
        wrapped.setObject(entry, forKey: WrappedKey(key))
        updatedSubject.send()
    }

    func value(forKey key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }

        guard Date() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }

        return entry.value
    }

    func valuePublisher(forKey key: Key) -> AnyPublisher<Value?, Never> {
        return Just<Value?>(value(forKey: key)).eraseToAnyPublisher()
    }

    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }

    func removeAll() {
        wrapped.removeAllObjects()
    }
}

private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) {
            self.key = key
        }

        override var hash: Int {
            key.hashValue
        }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }

    final class Entry: NSDiscardableContent {
        let value: Value
        let expirationDate: Date

        init(value: Value, expirationDate: Date) {
            self.value = value
            self.expirationDate = expirationDate
        }

        func beginContentAccess() -> Bool { true }

        func endContentAccess() {}

        func discardContentIfPossible() {}

        func isContentDiscarded() -> Bool { false }
    }
}

extension Cache {
    subscript(key: Key) -> Value? {
        get { value(forKey: key) }
        set {
            guard let value = newValue else {
                removeValue(forKey: key)
                return
            }

            insert(value, forKey: key)
        }
    }
}
