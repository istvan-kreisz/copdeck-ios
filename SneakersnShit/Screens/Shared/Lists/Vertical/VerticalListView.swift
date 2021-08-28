//
//  VerticalListView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/17/21.
//

import SwiftUI
import Combine

struct VerticalListView<Content: View, ToolBar: View>: View {
    let toolbar: ToolBar?
    let content: Content
    let bottomPadding: CGFloat
    let spacing: CGFloat

    init(bottomPadding: CGFloat = 0, spacing: CGFloat = 15, toolbar: ToolBar? = nil, @ViewBuilder content: () -> Content) {
        self.bottomPadding = bottomPadding
        self.spacing = spacing
        self.toolbar = toolbar
        self.content = content()
    }

    var body: some View {
        List {
            toolbar
                .listRow()
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
