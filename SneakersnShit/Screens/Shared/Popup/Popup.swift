//
//  Popup.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/15/21.
//

import SwiftUI
import UIKit

struct Popup<Content: View>: View {
    @Binding var isShowing: Bool
    let title: String
    let subtitle: String?
    let firstAction: ActionConfig
    let secondAction: ActionConfig?
    let content: Content?

    static var padding: CGFloat { 16 }
    static var buttonSpacing: CGFloat { 10 }

    var buttonCount: Int {
        secondAction == nil ? 1 : 2
    }

    var frameWidth: CGFloat {
        min(310, UIScreen.screenWidth - 16 * 2)
    }

    var buttonWidth: CGFloat {
        (frameWidth - Self.padding / 2 - Self.buttonSpacing) * 0.45
    }

    init(isShowing: Binding<Bool>,
         title: String,
         subtitle: String?,
         firstAction: ActionConfig,
         secondAction: ActionConfig?,
         @ViewBuilder content: () -> Content? = { nil }) {
        self._isShowing = isShowing
        self.title = title
        self.subtitle = subtitle
        self.firstAction = firstAction
        self.secondAction = secondAction
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color(r: 38, g: 38, b: 38, opacity: 0.62)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { isShowing = false }
            VStack(alignment: .center, spacing: 13) {
                Text(title)
                    .foregroundColor(.customText1)
                    .font(.bold(size: 25))

                if let subtitle = subtitle {
                    Text(subtitle)
                        .foregroundColor(.customText2)
                        .font(.regular(size: 12))
                }

                if let content = content {
                    content
                }

                HStack(alignment: .center, spacing: Self.buttonSpacing) {
                    RoundedButton<EmptyView>(text: firstAction.name,
                                             width: buttonWidth,
                                             height: 40,
                                             fontSize: 13,
                                             accessoryView: nil,
                                             tapped: firstAction.tapped)
                    if let secondAction = secondAction {
                        RoundedButton<EmptyView>(text: secondAction.name,
                                                 width: buttonWidth,
                                                 height: 40,
                                                 fontSize: 13,
                                                 accessoryView: nil,
                                                 tapped: secondAction.tapped)
                    }
                }
                .padding(.top, 16)
            }
            .padding(Self.padding)
            .frame(width: min(375, UIScreen.screenWidth - 16 * 2))
            .background(Color.customAccent4)
            .cornerRadius(Styles.cornerRadius)
            .withDefaultShadow()
        }
        .opacity(isShowing ? 1 : 0)
    }
}

struct Popup_Previews: PreviewProvider {
    static var previews: some View {
        Popup<EmptyView>(isShowing: .constant(true),
                         title: "im a popup",
                         subtitle: "im some description hey sup hello yoooo",
                         firstAction: .init(name: "im an action", tapped: {}),
                         secondAction: .init(name: "me too", tapped: {}))
    }
}
