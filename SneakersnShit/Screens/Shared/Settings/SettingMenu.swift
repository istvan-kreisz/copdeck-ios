//
//  SettingMenu.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/7/21.
//

import SwiftUI

struct SettingMenu<Content: View>: View {
    @Environment(\.presentationMode) var presentationMode

    let title: String
    let description: String?
    let buttonTitle: String
    let popBackOnSelect: Bool
    let buttonTapped: () -> Void
    let content: Content


    init(title: String, description: String? = nil, buttonTitle: String, popBackOnSelect: Bool, buttonTapped: @escaping () -> Void, @ViewBuilder _ content: () -> Content) {
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.popBackOnSelect = popBackOnSelect
        self.buttonTapped = buttonTapped
        self.content = content()
    }

    var body: some View {
        VStack {
            Text(title)
                .foregroundColor(.customText1)
                .font(.bold(size: 28))
                .leftAligned()
                .padding(.leading, 12)
            
            if let description = description {
                Text(description)
                    .foregroundColor(.customText2)
                    .font(.regular(size: 18))
                    .leftAligned()
                    .padding(.leading, 12)
                    .padding(.top, 8)
            }

            List {
                content
                Color.clear.padding(.bottom, 137)
                    .listRow(backgroundColor: .customWhite)
            }
        }
        .padding(.top, 30)
        .withFloatingButton(button: NextButton(text: buttonTitle,
                                               size: .init(width: 260, height: 60),
                                               color: .customBlack,
                                               tapped: {
                                                   buttonTapped()
                                                   if popBackOnSelect {
                                                       presentationMode.wrappedValue.dismiss()
                                                   }
                                               })
                .centeredHorizontally()
                .padding(.top, 20))
        .hideKeyboardOnScroll()
    }
}
