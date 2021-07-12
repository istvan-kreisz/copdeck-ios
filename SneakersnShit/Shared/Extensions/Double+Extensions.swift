//
//  Double+Extensions.swift
//  SneakersnShit
//
//  Created by István Kreisz on 7/11/21.
//

import Foundation

extension Double {
    func rounded(toPlaces places: Int) -> String {
        String(format: "%.\(places)f", self)
    }
}
