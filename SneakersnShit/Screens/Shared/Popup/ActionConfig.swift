//
//  ActionConfig.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/15/21.
//

import Foundation

struct ActionConfig: Identifiable {
    let name: String
    let tapped: () -> Void

    var id: String { name }
}
