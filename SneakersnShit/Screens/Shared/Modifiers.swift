//
//  Modifiers.swift
//  ToDo
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
