//
//  Modifiers.swift
//  ToDo
//
//  Created by István Kreisz on 4/10/20.
//  Copyright © 2020 István Kreisz. All rights reserved.
//

import SwiftUI
import Combine

struct KeyboardAwareModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    private let offset: CGFloat
    
    init(offset: CGFloat) {
        self.offset = offset
    }

    private var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue }
                .map { $0.cgRectValue.height },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
       ).eraseToAnyPublisher()
    }

    func body(content: Content) -> some View {
        content
            .offset(x: 0, y: -keyboardHeight + offset - UIApplication.shared.safeAreaInsets().bottom)
            .onReceive(keyboardHeightPublisher) {
                self.keyboardHeight = $0
        }
    }
}

extension View {
    func KeyboardAwarePadding(offset: CGFloat = 0.0) -> some View {
        ModifiedContent(content: self, modifier: KeyboardAwareModifier(offset: offset))
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
    }
    
    init(padding: Padding = .all) {
        self.padding = padding
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.top, padding.contains(.top) ? 30 : 0)
            .padding(.bottom, padding.contains(.bottom) ? 90 : 0)
            .padding(.leading, padding.contains(.leading) ? 20 : 0)
            .padding(.trailing, padding.contains(.trailing) ? 20 : 0)
    }
}

struct DefaultShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(0.22), radius: 3, x: 0, y: 1)
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

extension View {
    func centeredHorizontally() -> some View {
        ModifiedContent(content: self, modifier: CenteredHorizontally())
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

extension View {
    func centeredVertically() -> some View {
        ModifiedContent(content: self, modifier: CenteredVertically())
    }
}
