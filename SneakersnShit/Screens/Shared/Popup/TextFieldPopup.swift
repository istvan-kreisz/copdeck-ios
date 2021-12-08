//
//  TextFieldPopup.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/15/21.
//

import SwiftUI
import UIKit

struct TextFieldPopup: View {
    @Binding var isShowing: Bool
    let title: String
    let subtitle: String?
    let placeholder: String
    let actionTitle: String
    let action: (String) -> Void

    @State private var text = ""

    var body: some View {
        Popup(isShowing: $isShowing,
              title: title,
              subtitle: subtitle,
              firstAction: .init(name: "cancel", tapped: { isShowing = false }),
              secondAction: .init(name: actionTitle,
                                  tapped: {
                                      action(text)
                                  })) {
                TextFieldRounded(title: nil,
                                 placeHolder: placeholder,
                                 style: .white,
                                 keyboardType: .default,
                                 text: $text,
                                 width: nil,
                                 addClearButton: true)
                    .padding(.top, 30)
                    .padding(.bottom, 5)
                    .padding(.horizontal, 10)
        }
        .onChange(of: isShowing) { value in
            if !value {
                text = ""
            }
        }
    }
}
