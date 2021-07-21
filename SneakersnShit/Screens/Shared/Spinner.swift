//
//  Spinner.swift
//  CopDeck
//
//  Created by István Kreisz on 4/11/20.
//  Copyright © 2020 István Kreisz. All rights reserved.
//

import UIKit
import SwiftUI

struct Spinner: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<Spinner>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Spinner>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
