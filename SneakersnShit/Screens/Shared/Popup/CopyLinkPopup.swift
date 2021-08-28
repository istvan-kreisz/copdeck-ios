//
//  CopyLinkPopup.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/28/21.
//

import SwiftUI
import UIKit

struct CopyLinkPopup: View {
    @Binding var isShowing: Bool
    let title: String
    let subtitle: String?
    let linkURL: String
    let actionTitle: String
    let action: (String) -> Void

    var body: some View {
        Popup(isShowing: $isShowing,
              title: title,
              subtitle: subtitle,
              firstAction: .init(name: "cancel", tapped: { isShowing = false }),
              secondAction: .init(name: actionTitle, tapped: {
                action(linkURL)
                isShowing = false
              })) {
                Text(linkURL)
                    .foregroundColor(.customText2)
                    .frame(width: nil, height: Styles.inputFieldHeight)
                    .padding(.horizontal, 17)
                    .background(Color.customWhite)
                    .cornerRadius(Styles.cornerRadius)
                    .withDefaultShadow()
                    .padding(.top, 30)
                    .padding(.bottom, 5)
                    .padding(.horizontal, 10)
        }
    }
}

struct CopyLinkPopup_Previews: PreviewProvider {
    static var previews: some View {
        CopyLinkPopup(isShowing: .constant(true),
                      title: "im a popup",
                      subtitle: "im a popup description",
                      linkURL: "google.com",
                      actionTitle: "Add") { _ in }
    }
}
