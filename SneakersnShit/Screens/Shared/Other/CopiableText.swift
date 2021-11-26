//
//  CopiableText.swift
//  CopDeck
//
//  Created by István Kreisz on 11/25/21.
//

import SwiftUI

struct CopiableText: View {
    let text: String?
    let defaultIfNil: String
    
    init(_ text: String?, defaultIfNil: String = "") {
        self.text = text
        self.defaultIfNil = defaultIfNil
    }

    var body: some View {
        if let text = text {
            Text(text)
                .withCopyMenu(stringToCopy: text)
        } else {
            Text(defaultIfNil)
        }
    }
}
