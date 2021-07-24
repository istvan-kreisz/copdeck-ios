//
//  Optional+Extensions.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/24/21.
//

import Foundation

extension Optional where Wrapped == Double {
    var asString: String {
        map { String(Int($0)) } ?? ""
    }
}

extension Optional where Wrapped == Int {
    var asString: String {
        map { String($0) } ?? ""
    }
}
