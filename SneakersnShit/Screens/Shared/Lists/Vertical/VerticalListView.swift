//
//  VerticalListView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/17/21.
//

import SwiftUI
import Combine

struct VerticalListView<Content: View>: View {
    enum ListRowStyle {
        case none
        case color(Color)
    }

    let content: Content
    let bottomPadding: CGFloat
    let spacing: CGFloat
    let addHorizontalPadding: Bool
    let listRowStyling: ListRowStyle

    init(bottomPadding: CGFloat = 0,
         spacing: CGFloat = 15,
         addHorizontalPadding: Bool = true,
         listRowStyling: ListRowStyle = .color(.customBackground),
         @ViewBuilder content: () -> Content) {
        self.bottomPadding = bottomPadding
        self.spacing = spacing
        self.addHorizontalPadding = addHorizontalPadding
        self.listRowStyling = listRowStyling
        self.content = content()
    }

    var body: some View {
        List {
            switch listRowStyling {
            case .none:
                content
                    .withDefaultPadding(padding: addHorizontalPadding ? .horizontal : [])
                    .padding(.top, spacing)
            case let .color(color):
                content
                    .withDefaultPadding(padding: addHorizontalPadding ? .horizontal : [])
                    .padding(.top, spacing)
                    .listRow(backgroundColor: color)
            }

            if bottomPadding != 0 {
                switch listRowStyling {
                case .none:
                    Color.clear.padding(.bottom, bottomPadding)
                case let .color(color):
                    Color.clear.padding(.bottom, bottomPadding)
                        .listRow(backgroundColor: color)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}
