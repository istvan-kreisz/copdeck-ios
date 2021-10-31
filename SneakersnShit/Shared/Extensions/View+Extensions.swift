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

    func withDefaultShadow(color: Color = .customAccent3) -> some View {
        ModifiedContent(content: self, modifier: DefaultShadow(color: color))
    }

    func withDefaultPadding(padding: DefaultPadding.Padding = .all) -> some View {
        ModifiedContent(content: self, modifier: DefaultPadding(padding: padding))
    }

    func navigationbarHidden() -> some View {
        ModifiedContent(content: self, modifier: NavigationbarHidden())
    }

    func asCard() -> some View {
        padding(.vertical, Styles.verticalPadding)
            .padding(.horizontal, Styles.horizontalPadding)
            .background(Color.customWhite)
            .cornerRadius(Styles.cornerRadius)
            .withDefaultShadow()
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

    func withTabViewWrapper<S: ObservableObject>(viewRouter: ViewRouter,
                                                 store: S,
                                                 backgroundColor: Color = .customBackground,
                                                 shouldShow: Binding<Bool> = .constant(true)) -> some View {
        ModifiedContent(content: self, modifier: WrappedTabView(viewRouter: viewRouter, store: store, backgroundColor: backgroundColor, shouldShow: shouldShow))
    }

    func withSnackBar(text: String, shouldShow: Binding<Bool>, actionText: String? = nil, action: (() -> Void)? = nil) -> some View {
        ModifiedContent(content: self, modifier: WithSnackbar(text: text, shouldShow: shouldShow, actionText: actionText, action: action))
    }

    func withPopup<Popup: View>(@ViewBuilder _ popup: () -> Popup) -> some View {
        ModifiedContent(content: self, modifier: WithPopup(popup))
    }

    func withImageViewer(shownImageURL: Binding<URL?>) -> some View {
        ModifiedContent(content: self, modifier: WithImageViewer(shownImageURL: shownImageURL))
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

    func listRow(backgroundColor: Color = .customBackground) -> some View {
        padding(.vertical, 6)
            .padding(.horizontal, 30)
            .listRowBackground(backgroundColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .listRowInsets(EdgeInsets(top: -2, leading: -30, bottom: -2, trailing: -30))
            .background(backgroundColor)
    }

    func withTellTip(text: String = "What's this?", didTap: @escaping () -> Void) -> some View {
        ModifiedContent(content: self, modifier: WithTellTip(text: text, didTap: didTap))
    }

    func lockedContent(style: LockedContent.Style, lockSize: CGFloat, lockColor: Color = .customText1, lockEnabled: Bool = true) -> some View {
        ModifiedContent(content: self,
                        modifier: LockedContent(isLocked: AppStore.default.state.globalState.isContentLocked && lockEnabled,
                                                lockSize: lockSize,
                                                lockColor: lockColor,
                                                style: style) {
                            AppStore.default.send(.paymentAction(action: .showPaymentView(show: true)))
                        })
    }

    func tabTitle() -> some View {
        self
            .foregroundColor(.customText1)
            .font(.bold(size: 35))
            .leftAligned()
            .padding(.leading, 6)
    }
}

#if DEBUG
    private let rainbowDebugColors = [Color.purple, Color.blue, Color.green, Color.yellow, Color.orange, Color.red]

    extension View {
        func rainbowDebug() -> some View {
            self.background(rainbowDebugColors.randomElement()!)
        }
    }

#endif
