//
//  Date+Extensions.swift
//  CopDeck
//
//  Created by István Kreisz on 10/2/21.
//

import Foundation

extension Date {
    static var serverDate: Double {
        Date().timeIntervalSince1970 * 1000
    }
}
