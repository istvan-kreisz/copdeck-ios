//
//  EnumCodable.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/22/21.
//

import Foundation

protocol EnumCodable: RawRepresentable, Codable where RawValue == String {}

extension EnumCodable {
    init(from decoder: Decoder) throws {
        let string = try decoder.singleValueContainer().decode(String.self)
        if let value = Self(rawValue: string.capitalizingFirstLetter()) {
            self = value
        } else {
            throw NSError(domain: "", code: 1, userInfo: nil)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue.capitalized)
    }
}
