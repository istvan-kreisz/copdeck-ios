//
//  Collection+Extensions.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/15/21.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
