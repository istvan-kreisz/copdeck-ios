//
//  Double+Extensions.swift
//  CopDeck
//
//  Created by István Kreisz on 7/11/21.
//

import Foundation

extension Double {
    func rounded(toPlaces places: Int) -> String {
        String(format: "%.\(places)f", self)
    }
}

extension Optional where Wrapped == Double {
    var asString: String {
        map { String($0) } ?? ""
    }
}
