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
    let addHorizontalPadding: Bool
    let addListRowStyling: Bool

    init(bottomPadding: CGFloat = 0,
         spacing: CGFloat = 15,
         addHorizontalPadding: Bool = true,
         addListRowStyling: Bool = true,
         @ViewBuilder content: () -> Content) {
        self.bottomPadding = bottomPadding
        self.spacing = spacing
        self.addHorizontalPadding = addHorizontalPadding
        self.addListRowStyling = addListRowStyling
        self.content = content()
    }

    var body: some View {
        List {
            if addListRowStyling {
                content
                    .withDefaultPadding(padding: addHorizontalPadding ? .horizontal : [])
                    .padding(.top, spacing)
                    .listRow()
            } else {
                content
                    .withDefaultPadding(padding: addHorizontalPadding ? .horizontal : [])
                    .padding(.top, spacing)
            }
            if bottomPadding != 0 {
                if addListRowStyling {
                    Color.clear.padding(.bottom, bottomPadding)
                        .listRow()
                } else {
                    Color.clear.padding(.bottom, bottomPadding)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}
