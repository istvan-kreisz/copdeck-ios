//
//  Overlay.swift
//  CopDeck
//
//  Created by István Kreisz on 10/3/21.
//

import UIKit
import SwiftUI

class OverlayView: UIView {
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.contains(where: {
            !$0.isHidden
                && $0.isUserInteractionEnabled
                && $0.point(inside: self.convert(point, to: $0), with: event)
        })
    }
}

struct Overlay: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> OverlayView {
        OverlayView()
    }

    func updateUIView(_ pageControl: OverlayView, context: Context) {}

    class Coordinator: NSObject {
        var overlay: Overlay

        init(_ overlay: Overlay) {
            self.overlay = overlay
        }
    }
}
