//
//  Decodable+Extensions.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/6/21.
//

import Foundation

extension Decodable {
    init?(from dict: Any) {
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed)
            let decoder = JSONDecoder()
            self = try decoder.decode(Self.self, from: data)
        } catch {
            print(error)
            return nil
        }
    }
}
