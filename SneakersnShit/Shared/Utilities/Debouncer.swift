//
//  Debouncer.swift
//  SneakersnShit
//
//  Created by István Kreisz on 3/28/21.
//

import Foundation

class Debouncer {
    private static var debounceWorkItems: [String: DispatchWorkItem] = [:]

    static func debounce(delay: DispatchTimeInterval, id: String, queue: DispatchQueue = .main, action: @escaping (() -> Void)) {
        debounceWorkItems[id]?.cancel()
        let newWorkItem = DispatchWorkItem { action() }
        debounceWorkItems[id] = newWorkItem
        queue.asyncAfter(deadline: .now() + delay, execute: newWorkItem)
    }
}

enum Throttler {
    private static var throttleWorkItems: [String: DispatchWorkItem] = [:]

    static func throttle(delay: DispatchTimeInterval, id: String, queue: DispatchQueue = .main, action: @escaping (() -> Void)) {
        if throttleWorkItems[id] != nil { return }

        let newWorkItem = DispatchWorkItem { action() }
        throttleWorkItems[id] = newWorkItem
        queue.async(execute: newWorkItem)

        queue.asyncAfter(deadline: .now() + delay) {
            throttleWorkItems.removeValue(forKey: id)
        }
    }
}
