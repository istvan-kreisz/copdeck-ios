//
//  Modifiers.swift
//  CopDeck
//
//  Created by István Kreisz on 4/10/20.
//  Copyright © 2020 István Kreisz. All rights reserved.
//

import SwiftUI
import Combine

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

    func body(content: Content) -> some View {
        content
            .padding(.top, padding.contains(.top) ? 10 : 0)
            .padding(.bottom, padding.contains(.bottom) ? 30 : 0)
            .padding(.leading, padding.contains(.leading) ? Styles.horizontalMargin : 0)
            .padding(.trailing, padding.contains(.trailing) ? Styles.horizontalMargin : 0)
    }
}

struct DefaultShadow: ViewModifier {
    var color: Color = .customAccent3

    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: 5, x: 0, y: 0)
    }
}

struct DefaultInsets: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowInsets(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
    }
}

struct WrappedTabView: ViewModifier {
    @ObservedObject var viewRouter: ViewRouter
    let backgroundColor: Color
    @Binding var shouldShow: Bool

    init(viewRouter: ViewRouter, backgroundColor: Color, shouldShow: Binding<Bool> = .constant(true)) {
        self.viewRouter = viewRouter
        self.backgroundColor = backgroundColor
        self._shouldShow = shouldShow
    }

    func body(content: Content) -> some View {
        NavigationView {
            content
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

struct WithImageViewer: ViewModifier {
    @Binding var shownImageURL: URL?

    func body(content: Content) -> some View {
        ZStack {
            content
            ImageViewer(image: $shownImageURL)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct LockedContent: ViewModifier {
    enum Style {
        case hideOriginal
        case overlay(offset: CGSize)
        case adjacentRight(spacing: CGFloat)
        case adjacentLeft(spacing: CGFloat)
        case blur(text: String)
    }

    let isLocked: Bool
    let lockSize: CGFloat
    let lockColor: Color
    let style: Style
    let didTap: () -> Void

    private func lock() -> some View {
        Image(systemName: "lock.fill")
            .font(.bold(size: lockSize))
            .foregroundColor(lockColor)
    }

    func body(content: Content) -> some View {
        if isLocked {
            switch style {
            case .hideOriginal:
                lock()
                    .onTapGesture(perform: didTap)
            case let .overlay(offset):
                ZStack {
                    content
                        .disabled(true)
                    lock()
                        .offset(offset)
                }
                .onTapGesture(perform: didTap)
            case let .adjacentLeft(spacing):
                HStack(spacing: spacing) {
                    lock()
                    content
                        .disabled(true)
                }
                .onTapGesture(perform: didTap)
            case let .adjacentRight(spacing):
                HStack(spacing: spacing) {
                    content
                        .disabled(true)
                    lock()
                }
                .onTapGesture(perform: didTap)
            case let .blur(text: text):
                ZStack {
                    content
                        .allowsHitTesting(false)
                        .blur(radius: 10)
                    HStack(spacing: 5) {
                        Text(text)
                            .foregroundColor(.customText1)
                            .font(.semiBold(size: 22))
                            .frame(maxWidth: UIScreen.screenWidth - Styles.horizontalMargin * 6)
                        lock()
                    }
                }
                .onTapGesture(perform: didTap)
            }
        } else {
            content
        }
    }
}

struct WithAlert: ViewModifier {
    @Binding var alert: (String, String)?

    func body(content: Content) -> some View {
        let presentErrorAlert = Binding<Bool>(get: { alert != nil }, set: { new in alert = new ? alert : nil })
        content
            .alert(isPresented: presentErrorAlert) {
                let title = alert?.0 ?? ""
                let description = alert?.1 ?? ""
                return Alert(title: Text(title), message: Text(description), dismissButton: Alert.Button.cancel(Text("Okay")))
            }
    }
}

struct Collapsible: ViewModifier {
    let isActive: Bool
    var title: String? = nil
    let buttonTitle: String
    var titleColor: Color? = nil
    let style: NewItemCard.Style
    let contentHeight: CGFloat
    var topPaddingWhenCollapsed: CGFloat = 0

    @State var isShowing = false
    var onHide: (() -> Void)?
    var onShow: (() -> Void)?
    var onTooltipTapped: (() -> Void)? = nil

    func body(content: Content) -> some View {
        let show = Binding<Bool>(get: { isShowing },
                                 set: { show in
                                     if show {
                                         onShow?()
                                     } else {
                                         onHide?()
                                     }
                                     isShowing = show
                                 })

        if isActive {
            VStack(alignment: .leading, spacing: 4) {
                if let title = title, show.wrappedValue {
                    HStack(alignment: .center, spacing: 3) {
                        Text(title)
                            .font(.regular(size: 12))
                            .foregroundColor(titleColor ?? (style == .card ? .customText1 : .customText2))
                            .padding(.leading, 5)
                        if let onTooltipTapped = onTooltipTapped {
                            Button(action: onTooltipTapped) {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.regular(size: 13))
                                    .foregroundColor(titleColor ?? (style == .card ? .customText1 : .customText2))
                            }
                        }
                    }
                }

                if show.wrappedValue {
                    HStack(alignment: .bottom, spacing: 4) {
                        content
                            .buttonStyle(PlainButtonStyle())
                        DeleteButton(style: .fill, size: .small, color: .customRed) {
                            show.wrappedValue = false
                        }
                        .padding(.bottom, (contentHeight - DeleteButton.size(.small)) / 2)
                        .buttonStyle(PlainButtonStyle())
                    }
                } else {
                    AccessoryButton(title: buttonTitle,
                                    color: .customAccent1,
                                    textColor: .customText1,
                                    fontSize: 11,
                                    height: 22,
                                    width: nil,
                                    accessoryViewSize: 15,
                                    imageName: "plus",
                                    buttonPosition: .right,
                                    tapped: { show.wrappedValue = true })
                        .padding(.top, 15)
                }
            }
            .padding(.top, show.wrappedValue ? 0 : topPaddingWhenCollapsed)
        } else {
            content
        }
    }
}

struct ClearButton: ViewModifier {
    @Binding var text: String
    let textFieldWidth: CGFloat?

    public func body(content: Content) -> some View {
        ZStack {
            content
            if !text.isEmpty {
                Button {
                    self.text = ""
                } label: {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(.customAccent1)
                }
                .rightAligned()
                .padding(.trailing, 7)
            }
        }
        .frame(width: textFieldWidth)
    }
}
