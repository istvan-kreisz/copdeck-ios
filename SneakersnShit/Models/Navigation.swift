//
//  Navigation.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/20/21.
//

import Foundation

struct Navigation<T> {
    let destination: T
    var show: Bool

    mutating func display() {
        show = true
    }

    mutating func hide() {
        show = false
    }
}

extension Navigation {
    init(destination: T) {
        self.destination = destination
        self.show = true
    }

    static func += (lhs: inout Navigation, rhs: T) {
        lhs = .init(destination: rhs)
    }
}
