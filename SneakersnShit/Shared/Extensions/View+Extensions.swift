//
//  View+Extensions.swift
//  CopDeck
//
//  Created by István Kreisz on 7/13/21.
//

import SwiftUI

extension View {
    func leftAligned() -> some View {
        ModifiedContent(content: self, modifier: LeftAligned())
    }

    func rightAligned() -> some View {
        ModifiedContent(content: self, modifier: RightAligned())
    }

    func topAligned() -> some View {
        ModifiedContent(content: self, modifier: TopAligned())
    }

    func bottomAligned() -> some View {
        ModifiedContent(content: self, modifier: BottomAligned())
    }

    func centeredVertically() -> some View {
        ModifiedContent(content: self, modifier: CenteredVertically())
    }

    func centeredHorizontally() -> some View {
        ModifiedContent(content: self, modifier: CenteredHorizontally())
    }

    func withDefaultShadow() -> some View {
        ModifiedContent(content: self, modifier: DefaultShadow())
    }

    func withDefaultPadding(padding: DefaultPadding.Padding = .all) -> some View {
        ModifiedContent(content: self, modifier: DefaultPadding(padding: padding))
    }

    func navigationbarHidden() -> some View {
        ModifiedContent(content: self, modifier: NavigationbarHidden())
    }

    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder func `if`<TrueContent: View, FalseContent: View>(_ condition: Bool,
                                                                  if ifTransform: (Self) -> TrueContent,
                                                                  else elseTransform: (Self) -> FalseContent) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }

    func placeholder<Content: View>(when shouldShow: Bool,
                                    alignment: Alignment = .leading,
                                    @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
