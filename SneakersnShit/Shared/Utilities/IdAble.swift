//
//  IdAble.swift
//  SneakersnShit
//
//  Created by István Kreisz on 3/28/21.
//

import Foundation

protocol IdAble: RawRepresentable {
    var id: String { get }
}

extension IdAble {
    init?(rawValue: String) {
        return nil
    }

    var rawValue: String {
        guard let label = Mirror(reflecting: self).children.first?.label else {
            return .init(describing: self)
        }
        return label
    }

    var id: String { rawValue }
}
