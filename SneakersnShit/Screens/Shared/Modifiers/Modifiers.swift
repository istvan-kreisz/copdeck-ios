//
//  Modifiers.swift
//  CopDeck
//
//  Created by István Kreisz on 4/10/20.
//  Copyright © 2020 István Kreisz. All rights reserved.
//

import SwiftUI
import Combine

struct NavigationbarHidden: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarTitle("")
            .navigationBarHidden(true)
    }
}

struct DefaultPadding: ViewModifier {
    let padding: Padding

    struct Padding: OptionSet {
        let rawValue: Int

        static let top = Padding(rawValue: 1 << 0)
        static let bottom = Padding(rawValue: 1 << 1)
        static let leading = Padding(rawValue: 1 << 2)
        static let trailing = Padding(rawValue: 1 << 3)
        static let all: Padding = [.top, .bottom, .leading, .trailing]
        static let horizontal: Padding = [.leading, .trailing]
        static let vertical: Padding = [.top, .bottom]
    }

    init(padding: Padding = .all) {
        self.padding = padding
    }

    #warning("refactor margins + paddings")
    func body(content: Content) -> some View {
        content
            .padding(.top, padding.contains(.top) ? 20 : 0)
            .padding(.bottom, padding.contains(.bottom) ? 30 : 0)
            .padding(.leading, padding.contains(.leading) ? Styles.horizontalMargin : 0)
            .padding(.trailing, padding.contains(.trailing) ? Styles.horizontalMargin : 0)
    }
}

struct DefaultShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.customAccent3, radius: 5, x: 0, y: 0)
    }
}

struct DefaultInsets: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowInsets(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
    }
}

struct CenteredHorizontally: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
            Spacer()
        }
    }
}

struct CenteredVertically: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            Spacer()
            content
            Spacer()
        }
    }
}

struct LeftAligned: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
        }
    }
}

struct RightAligned: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
        }
    }
}

struct TopAligned: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            content
            Spacer()
        }
    }
}

struct BottomAligned: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            Spacer()
            content
        }
    }
}

struct WrappedTabView: ViewModifier {
    @ObservedObject var viewRouter: ViewRouter
    let store: AppStore
    let backgroundColor: Color
    @Binding var shouldShow: Bool

    init(viewRouter: ViewRouter, store: AppStore, backgroundColor: Color, shouldShow: Binding<Bool> = .constant(true)) {
        self.viewRouter = viewRouter
        self.store = store
        self.backgroundColor = backgroundColor
        self._shouldShow = shouldShow
    }

    func body(content: Content) -> some View {
        NavigationView {
            content
                .environmentObject(store)
                .edgesIgnoringSafeArea(.bottom)
                .frame(maxWidth: UIScreen.main.bounds.width)
                .withDefaultPadding(padding: .top)
                .withBackgroundColor(backgroundColor)
                .withFloatingButton(button: TabBar(viewRouter: viewRouter), shouldShow: $shouldShow)
                .navigationbarHidden()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct WithFloatingButton<V: View>: ViewModifier {
    var button: V
    @Binding var shouldShow: Bool

    init(button: V, shouldShow: Binding<Bool> = .constant(true)) {
        self.button = button
        self._shouldShow = shouldShow
    }

    func body(content: Content) -> some View {
        ZStack {
            content
            VStack {
                Spacer()
                    .layoutPriority(2)
                if shouldShow {
                    button
                        .layoutPriority(2)
                }
                Spacer(minLength: 35)
            }
        }
    }
}

struct WithBackgroundColor: ViewModifier {
    let color: Color

    init(_ color: Color = .customBackground, ignoringSafeArea: Edge.Set = .all) {
        self.color = color
    }

    func body(content: Content) -> some View {
        ZStack {
            color.edgesIgnoringSafeArea(.all)
            content
        }
    }
}

struct WithKeyboardHideOnScroll: ViewModifier {
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(DragGesture()
                .onChanged {
                    if abs($0.translation.height) > 0 {
                        UIApplication.shared.endEditing()
                    }
                })
    }
}

struct WithSnackbar: ViewModifier {
    @Binding var shouldShow: Bool
    let text: String
    let actionText: String?
    let action: (() -> Void)?

    init(text: String, shouldShow: Binding<Bool>, actionText: String? = nil, action: (() -> Void)? = nil) {
        self._shouldShow = shouldShow
        self.text = text
        self.actionText = actionText
        self.action = action
    }

    func body(content: Content) -> some View {
        ZStack {
            content
            Snackbar(isShowing: $shouldShow, text: text, actionText: actionText, action: action)
        }
    }
}

struct WithPopup<Popup: View>: ViewModifier {
    let popup: Popup

    init(@ViewBuilder _ popup: () -> Popup) {
        self.popup = popup()
    }

    func body(content: Content) -> some View {
        ZStack {
            content
            popup
        }
    }
}

struct WithTextFieldPopup: ViewModifier {
    @Binding var isShowing: Bool
    let title: String
    let subtitle: String?
    let placeHolder: String
    let actionTitle: String
    let action: (String) -> Void

    func body(content: Content) -> some View {
        ZStack {
            content
            TextFieldPopup(isShowing: $isShowing,
                           title: title,
                           subtitle: subtitle,
                           placeholder: placeHolder,
                           actionTitle: actionTitle) {
                    action($0)
                    isShowing = false
            }
        }
    }
}

struct WithTellTip: ViewModifier {
    let text: String
    let didTap: () -> Void

    func body(content: Content) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            content
                .layoutPriority(2)
            Button(action: didTap) {
                HStack(alignment: .bottom, spacing: 3) {
                    Text(text)
                        .underline()
                        .lineLimit(1)
                        .font(.bold(size: 12))
                        .foregroundColor(.customText2)
                    Image(systemName: "questionmark.circle.fill")
                        .font(.bold(size: 12))
                        .foregroundColor(.customText2)
                }
            }
            .layoutPriority(1)
            Spacer()
        }
    }
}
