//
//  List+Extensions.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/16/21.
//

import SwiftUI

extension View {
    @ViewBuilder func noSeparators() -> some View {
        accentColor(Color.customBackground)
            .listStyle(PlainListStyle())
            .background(Color.customBackground)
    }
}
