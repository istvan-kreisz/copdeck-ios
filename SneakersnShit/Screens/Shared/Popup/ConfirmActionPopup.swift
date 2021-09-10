//
//  ConfirmActionPopup.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/10/21.
//

import SwiftUI

struct ConfirmActionPopup: View {
    @Binding var isShowing: Bool
    let title: String
    let subtitle: String?
    let actionName: String
    let action: () -> Void

    var body: some View {
        Popup<EmptyView>(isShowing: $isShowing,
                         title: title,
                         subtitle: subtitle,
                         firstAction: .init(name: "Cancel", tapped: { isShowing = false }),
                         secondAction: .init(name: actionName, tapped: {
                             isShowing = false
                             action()
                         }))
    }
}
