//
//  UserDefaults+Extensions.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/25/21.
//

import Foundation

extension UserDefaults {

    enum Keys: String, CaseIterable {
        case needsAppOnboarding
        case didPublish
    }

    func reset() {
        Keys.allCases.forEach { removeObject(forKey: $0.rawValue) }
    }

}
