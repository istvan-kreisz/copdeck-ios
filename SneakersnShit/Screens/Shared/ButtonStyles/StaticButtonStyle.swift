//
//  StaticButtonStyle.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/20/21.
//

import SwiftUI

struct StaticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
