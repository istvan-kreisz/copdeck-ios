//
//  Debouncer.swift
//  CopDeck
//
//  Created by István Kreisz on 3/28/21.
//

import Foundation

class Debouncer {
    private static var debounceWorkItems: [String: DispatchWorkItem] = [:]
    private static var debounceCancelItems: [String: DispatchWorkItem] = [:]

    static func debounce(delay: DispatchTimeInterval, id: String, queue: DispatchQueue = .main, action: @escaping (() -> Void), cancel: @escaping (() -> Void)) {
        DispatchQueue.main.async {
            debounceWorkItems[id]?.cancel()
            debounceCancelItems[id]?.perform()

            let newWorkItem = DispatchWorkItem { action() }
            let newCancelItem = DispatchWorkItem { cancel() }

            debounceWorkItems[id] = newWorkItem
            debounceCancelItems[id] = newCancelItem

            queue.asyncAfter(deadline: .now() + delay) {
                debounceWorkItems[id]?.perform()
                debounceCancelItems[id]?.cancel()
                debounceWorkItems[id] = nil
                debounceCancelItems[id] = nil
            }
        }
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
