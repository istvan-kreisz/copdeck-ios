//
//  VerticalListView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/17/21.
//

import SwiftUI
import Combine

struct VerticalListView<Content: View>: View {
    let content: Content
    let bottomPadding: CGFloat
    let spacing: CGFloat

    init(bottomPadding: CGFloat = 0, spacing: CGFloat = 15, @ViewBuilder content: () -> Content) {
        self.bottomPadding = bottomPadding
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        List {
            content
                .withDefaultPadding(padding: .horizontal)
                .padding(.top, spacing)
                .listRow()

            Color.clear.padding(.bottom, bottomPadding)
                .listRow()
        }
        .listStyle(PlainListStyle())
    }
}
