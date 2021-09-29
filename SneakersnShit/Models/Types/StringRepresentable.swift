//
//  StringRepresentable.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/29/21.
//

import Foundation

protocol StringRepresentable {
    var label: String { get }
}

extension StringRepresentable {
    var label: String {
        let mirror = Mirror(reflecting: self)
        if let label = mirror.children.first?.label {
            return label
        } else {
            return String(describing: self)
        }
    }
}
