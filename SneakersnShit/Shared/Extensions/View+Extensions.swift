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

    func withFloatingButton<V: View>(button: V, shouldShow: Binding<Bool> = .constant(true)) -> some View {
        ModifiedContent(content: self, modifier: WithFloatingButton(button: button, shouldShow: shouldShow))
    }

    func hideKeyboardOnScroll() -> some View {
        ModifiedContent(content: self, modifier: WithKeyboardHideOnScroll())
    }

    func withBackgroundColor(_ color: Color = .customBackground, ignoringSafeArea edges: Edge.Set = .all) -> some View {
        ModifiedContent(content: self, modifier: WithBackgroundColor(color, ignoringSafeArea: edges))
    }

    func withTabViewWrapper(viewRouter: ViewRouter, store: AppStore, shouldShow: Binding<Bool> = .constant(true)) -> some View {
        ModifiedContent(content: self, modifier: WrappedTabView(viewRouter: viewRouter, store: store, shouldShow: shouldShow))
    }

    func withSnackBar(text: String, shouldShow: Binding<Bool>, actionText: String? = nil, action: (() -> Void)? = nil) -> some View {
        ModifiedContent(content: self, modifier: WithSnackbar(text: text, shouldShow: shouldShow, actionText: actionText, action: action))
    }

    func withTextFieldPopup(isShowing: Binding<Bool>,
                            title: String,
                            subtitle: String?,
                            placeholder: String,
                            actionTitle: String,
                            action: @escaping (String) -> Void) -> some View {
        ModifiedContent(content: self, modifier: WithTextFieldPopup(isShowing: isShowing,
                                                                    title: title,
                                                                    subtitle: subtitle,
                                                                    placeHolder: placeholder,
                                                                    actionTitle: actionTitle,
                                                                    action: action))
    }
}
