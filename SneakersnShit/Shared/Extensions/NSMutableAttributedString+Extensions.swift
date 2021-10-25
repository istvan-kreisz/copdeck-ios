//
//  NSMutableAttributedString+Extensions.swift
//  CopDeck
//
//  Created by István Kreisz on 10/25/21.
//

import Foundation

extension NSMutableAttributedString {
    @discardableResult func setAsLink(textToFind: String, linkURL: String) -> Bool {
        let foundRange = mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            addAttribute(.link, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
}
