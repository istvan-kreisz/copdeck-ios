//
//  Encodable.swift
//  SneakersnShit
//
//  Created by István Kreisz on 3/30/21.
//

import Foundation

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let encodedSelf = try JSONEncoder().encode(self)
        if let dictionary = try JSONSerialization.jsonObject(with: encodedSelf) as? [String: Any] {
            return dictionary
        } else {
            throw AppError(title: "Encoding Model Failed", message: "", error: nil)
        }
    }

    var asJSON: Any? {
        guard let encodedConfig = try? JSONEncoder().encode(self),
              let json = try? JSONSerialization.jsonObject(with: encodedConfig, options: .allowFragments)
        else { return nil }
        return json
    }

    func decode() -> Self? {
        nil
    }
}
