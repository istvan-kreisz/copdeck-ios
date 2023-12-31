//
//  PagerView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/15/21.
//

import SwiftUI

struct PagerView<Content: View>: View {
    @Binding var pageCount: Int
    @Binding var currentIndex: Int
    let content: Content

    @GestureState private var translation: CGFloat = 0

    var index: Int {
        min(pageCount - 1, currentIndex)
    }

    init(pageCount: Binding<Int>, currentIndex: Binding<Int>, @ViewBuilder content: () -> Content) {
        self._pageCount = pageCount
        self._currentIndex = currentIndex
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            LazyHStack(spacing: 0) {
                content.frame(width: geometry.size.width)
            }
            .frame(width: geometry.size.width, alignment: .leading)
            .offset(x: -CGFloat(index) * geometry.size.width)
            .offset(x: pageCount == 1 ? 0 : translation)
            .animation(.interactiveSpring(), value: index)
            .animation(.interactiveSpring(), value: translation)
            .simultaneousGesture(DragGesture().updating($translation) { value, state, _ in
                state = value.translation.width
            }.onEnded { value in
                let offset = value.translation.width / geometry.size.width
                let newIndex = (CGFloat(index) - offset).rounded()
                currentIndex = min(max(Int(newIndex), 0), pageCount - 1)
            })
        }
    }
}
