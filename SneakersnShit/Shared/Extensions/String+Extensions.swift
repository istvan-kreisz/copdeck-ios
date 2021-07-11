//
//  String+Extensions.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/11/21.
//

import Foundation

extension String {
    var number: Int? {
        Int(components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
}
