//
//  NewTagPopup.swift
//  CopDeck
//
//  Created by István Kreisz on 11/9/21.
//

import SwiftUI
import UIKit

struct NewTagPopup: View {
    @Binding var isShowing: Bool
    let action: (_ name: String, _ color: String) -> Void

    @State private var name = ""
    @State private var color = "blue"

    var body: some View {
        Popup(isShowing: $isShowing,
              title: "Add new tag",
              subtitle: nil,
              firstAction: .init(name: "cancel", tapped: { isShowing = false }),
              secondAction: .init(name: "Add Tag", tapped: {
            action(name, color)
            isShowing = false
        })) {
            VStack(spacing: 15) {
                TextFieldRounded(title: nil,
                                 placeHolder: "Your new tag's name",
                                 style: .white,
                                 keyboardType: .default,
                                 text: $name,
                                 width: nil,
                                 addClearButton: true)
                    
                ColorSelectorMenu(color: $color)
            }
            .padding(.horizontal, 10)
            .padding(.top, 30)
            .padding(.bottom, 5)
        }
        .onChange(of: isShowing) { value in
            if !value {
                name = ""
            }
        }
    }
}
